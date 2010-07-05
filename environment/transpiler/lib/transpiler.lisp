;;;;; TRE tree processor transpiler
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

(defvar *show-definitions?* nil)

;; Set this when starting up your transpiler run.
(defvar *current-transpiler* nil)

(defvar *transpiler-assert* nil)
(defvar *transpiler-log* nil)

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

  ; Generator for literal strings.
  (gen-string (fn transpiler-make-escaped-string _ #\"))

  ; Tells if functions must be moved out of functions.
  (lambda-export? nil)

  ; Tells if arguments are passed by stack.
  (stack-arguments? nil)

  (needs-var-declarations? nil)

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

  (predefined-symbols nil)

  ; Literals that must be declared or cached before code with them is emitted.
  (compiled-chars (make-hash-table :test #'=))
  (compiled-numbers (make-hash-table :test #'=))
  (compiled-strings (make-hash-table :test #'eq))
  (compiled-symbols (make-hash-table :test #'eq))
  (compiled-decls nil)
  (compiled-inits nil))

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

(define-slot-setter-push! transpiler-add-dont-inline tr
  (transpiler-dont-inline tr))

(defun transpiler-add-obfuscation-exceptions (tr &rest x)
  (dolist (i x)
	(setf (href (transpiler-obfuscations tr) (make-symbol (symbol-name i)))
		  t)))

(define-slot-setter-push! transpiler-add-plain-arg-fun tr
  (transpiler-plain-arg-funs tr))

(define-slot-setter-push! transpiler-add-exported-closure tr
  (transpiler-exported-closures tr))

(defun transpiler-plain-arg-fun? (tr fun)
  (member fun (transpiler-plain-arg-funs tr) :test #'eq))

(defun transpiler-dont-inline? (tr fun)
  (member fun (transpiler-dont-inline tr) :test #'eq))

(defun transpiler-macro (tr name)
  (let expander (expander-get (transpiler-macro-expander tr))
    (funcall (expander-lookup expander)
			 expander
		     name)))

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
  		(transpiler-exported-closures tr) nil)
  (transpiler-add-obfuscation-exceptions tr (make-symbol ""))
  tr)
