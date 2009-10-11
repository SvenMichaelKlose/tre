;;;;; TRE tree processor transpiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Configuration

;; Set this when starting up your transpiler run.
(defvar *current-transpiler* nil)

(defvar *transpiler-assert* nil)

(defstruct transpiler
  std-macro-expander
  macro-expander
  (setf-functionp #'identity)
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
  (defined-functions-hash (make-hash-table :test #'eq))

  ; functinos required by transpiled code. It is imported from the
  ; environment.
  (wanted-functions nil)
  (wanted-functions-hash (make-hash-table :test #'eq))

  (wanted-variables nil)
  (wanted-variables-hash (make-hash-table :test #'eq))

  (defined-variables nil)
  (defined-variables-hash (make-hash-table :test #'eq))

  ; Tells if target required named top-level functions (like C).
  (named-functions? nil)

  (inline-exceptions nil)
  (dont-inline nil)

  (obfuscate? nil)
  (import-from-environment? t)

  (make-label #'identity)
  (preprocessor #'identity)

  ; Generator for literal strings.
  (gen-string #'((tr str) (string-concat "\"" str "\"")))

  ; Tells if functions must be moved out of functions.
  (lambda-export? nil)

  ; Tells if arguments are passed by stack.
  (stack-arguments? nil)

  ; Tells if local variables are on the stack.
  (stack-locals? nil)

  (apply-argdefs? nil)

  (inject-function-names? nil)

  ; You shouldn't have to tweak these at construction-time:
  (symbol-translations nil)
  thisify-classes
  (function-args (make-hash-table :test #'eq))
  (function-bodies (make-hash-table :test #'eq))
  emitted-wanted-functions
  (obfuscations (make-hash-table :test #'eq))
  plain-arg-funs
  (exported-closures nil)
  (rename-all-args? nil)

  ; Literals that must be declared or cached before code with them is emitted.
  (compiled-chars (make-hash-table :test #'=))
  (compiled-numbers (make-hash-table :test #'=))
  (compiled-strings (make-hash-table :test #'eq))
  (compiled-symbols (make-hash-table :test #'eq))
  (compiled-decls nil)
  (compiled-inits nil))

(defun transpiler-reset (tr)
  (setf (transpiler-thisify-classes tr) (make-hash-table)	; thisified classes.
  		(transpiler-function-args tr) nil
  		(transpiler-emitted-wanted-functions tr) nil
  		(transpiler-wanted-functions tr) nil
  		(transpiler-wanted-functions-hash tr) (make-hash-table :test #'eq)
  		(transpiler-wanted-variables tr) nil
  		(transpiler-wanted-variables-hash tr) (make-hash-table :test #'eq)
  		(transpiler-defined-functions tr) nil
  		(transpiler-defined-functions-hash tr) (make-hash-table :test #'eq)
  		(transpiler-defined-variables tr) nil
  		(transpiler-defined-variables-hash tr) (make-hash-table :test #'eq)
  		(transpiler-function-args tr) (make-hash-table :test #'eq)
  		(transpiler-exported-closures tr) nil))

(defun transpiler-defined-function (tr name)
  (href (transpiler-defined-functions-hash tr) name))

(defun transpiler-add-defined-function (tr name)
  (push! name (transpiler-defined-functions tr))
  (setf (href (transpiler-defined-functions-hash tr) name) t)
  name)

(defun transpiler-defined-variable (tr name)
  (href (transpiler-defined-variables-hash tr) name))

(defun transpiler-add-defined-variable (tr name)
  (push! name (transpiler-defined-variables tr))
  (setf (href (transpiler-defined-variables-hash tr) name) t)
  name)

(defun transpiler-switch-obfuscator (tr on?)
  (setf (transpiler-obfuscate? tr) on?))

(defun transpiler-function-arguments (tr fun)
  (href (transpiler-function-args tr) fun))

(defun transpiler-function-body (tr fun)
  (href (transpiler-function-bodies tr) fun))

(defun transpiler-add-function-args (tr fun args)
  (setf (href (transpiler-function-args tr) fun) args))

(defun transpiler-add-function-body (tr fun args)
  (setf (href (transpiler-function-bodies tr) fun) args))

(define-slot-setter-push! transpiler-add-unwanted-function tr
  (transpiler-unwanted-functions tr))

(define-slot-setter-push! transpiler-add-emitted-wanted-function tr
  (transpiler-emitted-wanted-functions tr))

(defun transpiler-wanted-function? (tr fun)
  (href (transpiler-wanted-functions-hash tr) fun))

(defun transpiler-wanted-variable? (tr name)
  (href (transpiler-wanted-variables-hash tr) name))

(defun transpiler-unwanted-function? (tr fun)
  (member fun (transpiler-unwanted-functions tr)))

(defun transpiler-inline-exception? (tr fun)
  (member fun (transpiler-inline-exceptions tr) :test #'eq))

(define-slot-setter-push! transpiler-add-inline-exception tr
  (transpiler-inline-exceptions tr))

(defun transpiler-add-obfuscation-exceptions (tr &rest x)
  (dolist (i x)
	(setf (href (transpiler-obfuscations tr) i) t)))

(define-slot-setter-push! transpiler-add-plain-arg-fun tr
  (transpiler-plain-arg-funs tr))

(define-slot-setter-push! transpiler-add-exported-closure tr
  (transpiler-exported-closures tr))

(defun transpiler-plain-arg-fun? (tr fun)
  (member fun (transpiler-plain-arg-funs tr)))

(defun transpiler-dont-inline? (tr fun)
  (member fun (transpiler-dont-inline tr)))

(defun transpiler-macro (tr name)
  (let expander (expander-get (transpiler-macro-expander tr))
    (funcall (expander-lookup expander)
			 expander
		     name)))

;; Make expander for standard macro which picks macros of the same
;; name in der user-defined expander first.
(defun make-overlayed-std-macro-expander (expander-name)
  #'%%macrop
  #'%%macrocall
  (with (e (define-expander expander-name)
         mypred (expander-pred e)
		 mycall (expander-call e))
    (setf (expander-pred e) (lx (mypred)
								(fn (or (funcall ,mypred _)
				 				        (%%macrop _))))
   		  (expander-call e) (lx (mypred mycall)
								(fn (if (funcall ,mypred _)
				 				        (funcall ,mycall _)
				 				        (%%macrocall _)))))))

(defun transpiler-make-std-macro-expander (tr)
 (make-overlayed-std-macro-expander (transpiler-std-macro-expander tr)))

(defun transpiler-make-code-expander (tr)
  (define-expander (transpiler-macro-expander tr)))

(defun transpiler-make-expex (tr)
  #'transpiler-add-wanted-function
  #'transpiler-add-wanted-variable
  #'transpiler-plain-arg-fun?
  (let ex (make-expex)
    (setf (transpiler-expex tr) ex

		  (expex-transpiler ex)
			tr

		  (expex-function-collector ex)
		    (lx (tr)
				#'((fun args)
			         (transpiler-add-wanted-function ,tr fun)))

		  (expex-argument-filter ex)
		    (lx (tr)
		    	#'((var)
			         (transpiler-add-wanted-variable ,tr var)))

		  (expex-function? ex)
		    (lx (tr)
				#'((fun)
			         (when (atom fun)
			           (or (transpiler-function-arguments ,tr fun)
				           (and (not (transpiler-unwanted-function? ,tr fun))
					            (functionp (symbol-function fun)))))))

		  (expex-function-arguments ex)
		    (lx (tr)
				#'((fun)
			         (or (transpiler-function-arguments ,tr fun)
				         (function-arguments (symbol-function fun)))))

		  (expex-plain-arg-fun? ex)
		    (lx (tr)
				#'((fun)
			         (transpiler-plain-arg-fun? ,tr fun)))
		  (expex-expr-filter ex)
			#'transpiler-import-from-expex)
	ex))

(defun create-transpiler (&rest args)
  (let tr (apply #'make-transpiler args)
	(transpiler-reset tr)
	(transpiler-make-std-macro-expander tr)
	(transpiler-make-code-expander tr)
	(transpiler-make-expex tr)
	(transpiler-obfuscate-symbol tr nil)
	tr))
