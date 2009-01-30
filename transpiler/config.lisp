;;;;; TRE tree processor transpiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Configuration

(defstruct transpiler
  std-macro-expander
  macro-expander
  setf-functionp
  separator

  ; List of functions that must not be imported from the environment.
  unwanted-functions

  ; Predicate that tells if a character is legal in an identifier.
  (identifier-char?
	(fn error "structure 'transpiler': IDENTIFIER-CHAR? is not initialised"))

  (expex nil)

  ; Functions defined in transpiled code, not in the environment.
  (defined-functions nil)

  ; functinos required by transpiled code. It is imported from the
  ; environment.
  (wanted-functions nil)

  (wanted-variables nil)
  (defined-variables nil)

  ; Tells if target required named top-level functions (like C).
  (named-functions? nil)

  (obfuscate? nil)

  ; List of symbols that must not be obfuscated.
  (obfuscation-exceptions nil)

  (make-label #'identity)
  (preprocessor #'identity)

  ; Generator for literal strings.
  (gen-string #'((tr str) (string-concat "\"" str "\"")))

  ; Tells if functions must be moved out of functions.
  (lambda-export? nil)

  ; Tells if arguments are passed by stack.
  (stack-arguments? nil)

  ; You shouldn't have to tweak these at construction-time:
  (symbol-translations nil)
  thisify-classes
  function-args
  emitted-wanted-functions
  obfuscations)

(defun transpiler-reset (tr)
  (setf (transpiler-thisify-classes tr) (make-hash-table)	; thisified classes.
  		(transpiler-function-args tr) nil
  		(transpiler-emitted-wanted-functions tr) nil
  		(transpiler-obfuscations tr) (make-hash-table)))

(defun transpiler-defined-function (tr name)
  (member name (transpiler-defined-functions tr)))

(defun transpiler-defined-variable (tr name)
  (member name (transpiler-defined-variables tr)))

(defun transpiler-switch-obfuscator (tr on?)
  (setf  (transpiler-obfuscations tr) (make-hash-table)
		 (transpiler-obfuscate? tr) on?))

(defun transpiler-function-arguments? (tr fun)
  (assoc fun (transpiler-function-args tr)))

(defun transpiler-function-arguments (tr fun)
  (cdr (assoc fun (transpiler-function-args tr))))

(define-slot-setter-push! transpiler-add-unwanted-function tr
  (transpiler-unwanted-functions tr))

(defvar mypred nil)
(defvar mycall nil)
;; Make expander for standard macro which picks macros of the same
;; name in der user-defined expander first.
(defun make-overlayed-std-macro-expander (expander-name)
 (let e (define-expander expander-name)
   (setf mypred (expander-pred e)
		 mycall (expander-call e))
   (setf (expander-pred e) (fn (or (funcall mypred _)
				 				   (%%macrop _)))
   		 (expander-call e) (fn (if (funcall mypred _)
				 				   (funcall mycall _)
				 				   (%%macrocall _))))))

(defun transpiler-make-std-macro-expander (tr)
 (make-overlayed-std-macro-expander (transpiler-std-macro-expander tr)))

(defun transpiler-make-code-expander (tr)
  (define-expander (transpiler-macro-expander tr)
				   :call (fn transpiler-macrocall tr _)))

(defun transpiler-make-expex (tr)
  (let ex (make-expex)
    (setf (transpiler-expex tr) ex

		  (expex-function-collector ex)
		  #'((fun args)
			   (transpiler-add-wanted-function tr fun))

		  (expex-variable-collector ex)
		  #'((var)
			   (transpiler-add-wanted-variable tr var))

		  (expex-function? ex)
		  #'((fun)
			   (or (assoc fun (transpiler-function-args tr))
				   (and (or (eq t (transpiler-unwanted-functions tr))
						    (not (member fun (transpiler-unwanted-functions tr))))
						(functionp (symbol-function fun)))))

		  (expex-function-arguments ex)
		  #'((fun)
			   (or (transpiler-function-arguments tr fun)
				   (function-arguments (symbol-function fun)))))
	ex))

(defun create-transpiler (&rest args)
  (let tr (apply #'make-transpiler args)
	(transpiler-reset tr)
	(transpiler-make-std-macro-expander tr)
	(transpiler-make-code-expander tr)
	(transpiler-make-expex tr)
	tr))
