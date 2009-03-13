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

  (literal-conversion
	(fn error "structure 'transpiler': LITERAL-CONVERSION is not initialised"))

  (expex nil)

  ; Functions defined in transpiled code, not in the environment.
  (defined-functions nil)
  (defined-functions-hash (make-hash-table))

  ; functinos required by transpiled code. It is imported from the
  ; environment.
  (wanted-functions nil)
  (wanted-functions-hash (make-hash-table))

  (wanted-variables nil)
  (wanted-variables-hash (make-hash-table))

  (defined-variables nil)
  (defined-variables-hash (make-hash-table))

  ; Tells if target required named top-level functions (like C).
  (named-functions? nil)

  (obfuscate? nil)
  (import-from-environment? t)

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

  (apply-argdefs? nil)

  ; You shouldn't have to tweak these at construction-time:
  (symbol-translations nil)
  thisify-classes
  (function-args (make-hash-table))
  emitted-wanted-functions
  obfuscations
  plain-arg-funs
  (currently-imported-lambda nil)
  (exported-closures nil))

(defun transpiler-reset (tr)
  (setf (transpiler-thisify-classes tr) (make-hash-table)	; thisified classes.
  		(transpiler-function-args tr) nil
  		(transpiler-emitted-wanted-functions tr) nil
  		(transpiler-wanted-functions tr) nil
  		(transpiler-wanted-functions-hash tr) (make-hash-table)
  		(transpiler-wanted-variables tr) nil
  		(transpiler-wanted-variables-hash tr) (make-hash-table)
  		(transpiler-defined-functions tr) nil
  		(transpiler-defined-functions-hash tr) (make-hash-table)
  		(transpiler-defined-variables tr) nil
  		(transpiler-defined-variables-hash tr) (make-hash-table)
  		(transpiler-function-args tr) (make-hash-table)
  		(transpiler-exported-closures tr) nil
  		(transpiler-obfuscations tr) (make-hash-table)))

(defun transpiler-defined-function (tr name)
  (href name (transpiler-defined-functions-hash tr)))

(defun transpiler-add-defined-function (tr name)
  (push! name (transpiler-defined-functions tr))
  (setf (href name (transpiler-defined-functions-hash tr)) t)
  name)

(defun transpiler-defined-variable (tr name)
  (href name (transpiler-defined-variables-hash tr)))

(defun transpiler-add-defined-variable (tr name)
  (push! name (transpiler-defined-variables tr))
  (setf (href name (transpiler-defined-variables-hash tr)) t)
  name)

(defun transpiler-switch-obfuscator (tr on?)
  (setf (transpiler-obfuscations tr) (make-hash-table)
		(transpiler-obfuscate? tr) on?))

(defun transpiler-function-arguments (tr fun)
  (href fun (transpiler-function-args tr)))

(defun transpiler-add-function-args (tr fun args)
  (setf (href fun (transpiler-function-args tr)) args))

(define-slot-setter-push! transpiler-add-unwanted-function tr
  (transpiler-unwanted-functions tr))

(define-slot-setter-push! transpiler-add-emitted-wanted-function tr
  (transpiler-emitted-wanted-functions tr))

(defun transpiler-wanted-function? (tr fun)
  (href fun (transpiler-wanted-functions-hash tr)))

(defun transpiler-wanted-variable? (tr name)
  (href fun (transpiler-wanted-variables-hash tr)))

(defun transpiler-unwanted-function? (tr fun)
  (member fun (transpiler-unwanted-functions tr)))

(define-slot-setter-push! transpiler-add-plain-arg-fun tr
  (transpiler-plain-arg-funs tr))

(define-slot-setter-acons! transpiler-add-exported-closure tr
  (transpiler-exported-closures tr))

;; Needed for lambda-expansion of exported lambdas.
(defun transpiler-current-funinfo (tr)
  (assoc-value (transpiler-currently-imported-lambda tr)
	   		   (transpiler-exported-closures tr)))

;; Needed for lambda-expansion of exported lambdas.
(defun transpiler-current-env (tr)
  (awhen (transpiler-current-funinfo tr)
	(funinfo-env !)))

(defun transpiler-plain-arg-fun? (tr fun)
  (member fun (transpiler-plain-arg-funs tr)))

(defun transpiler-macro (tr name)
  (assoc name (expander-macros
                (expander-get
                  (transpiler-macro-expander tr)))))

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

		  (expex-argument-filter ex)
		    #'((var)
			     (transpiler-add-wanted-variable tr var))

		  (expex-function? ex)
		  #'((fun)
			   (and (atom fun)
			        (or (transpiler-function-arguments tr fun)
				        (and (not (transpiler-unwanted-function? tr fun))
						     (functionp (symbol-function fun))))))

		  (expex-function-arguments ex)
		  #'((fun)
			   (or (transpiler-function-arguments tr fun)
				   (function-arguments (symbol-function fun))))

		  (expex-plain-arg-fun? ex)
		  #'((fun)
			   (transpiler-plain-arg-fun? tr fun)))
	ex))

(defun create-transpiler (&rest args)
  (let tr (apply #'make-transpiler args)
	(transpiler-reset tr)
	(transpiler-make-std-macro-expander tr)
	(transpiler-make-code-expander tr)
	(transpiler-make-expex tr)
	tr))
