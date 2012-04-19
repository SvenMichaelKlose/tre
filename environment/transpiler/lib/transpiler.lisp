;;;;; tré - Copyright (c) 2008-2012 Sven Michael Klose <pixel@copei.de>

(defvar *current-transpiler* nil)
(defvar *transpiler-assert* nil)
(defvar *transpiler-log* nil)
(defvar *transpiler-no-stream?* nil)

(defvar *transpiler-except-cps?* t)
(defvar *show-definitions?* nil)
(defvar *opt-inline?* nil)
(defvar *recompiling?* nil)

(defstruct transpiler
  name
  std-macro-expander
  macro-expander
  (setf-function? #'identity)
  separator

  ; List of functions that must not be imported from the environment.
  unwanted-functions

  (identifier-char? (fn error "structure 'transpiler': IDENTIFIER-CHAR? is not initialised"))
  (literal-conversion (fn error "structure 'transpiler': LITERAL-CONVERSION is not initialised"))

  expex
  expex-initializer

  (defined-functions-hash (make-hash-table :test #'eq))
  (defined-variables-hash (make-hash-table :test #'eq))

  ; Functions to be imported from the environment.
  (wanted-functions nil)
  (wanted-functions-hash (make-hash-table :test #'eq))

  (wanted-variables nil)
  (wanted-variables-hash (make-hash-table :test #'eq))

  ; Tells if target required named top-level functions (like C).
  (named-functions? nil)
  (named-function-next nil)

  (inline-exceptions nil)
  (dont-inline-list nil)

  (obfuscate? nil)
  (import-from-environment? t)
  (save-sources? nil)
  (save-argument-defs-only? nil)

  ; Generator for literal strings.
  (gen-string (fn c-literal-string _ #\"))

  ; Tells if functions must be moved out of functions.
  (lambda-export? nil)

  (needs-var-declarations? nil)

  ; Tells if local variables are on the stack.
  (stack-locals? nil)

  (place-expand-ignore-toplevel-funinfo? nil)

  (apply-argdefs? nil)

  (continuation-passing-style? nil)
  (cps-exceptions nil)
  (cps-functions nil)

  ; You shouldn't have to tweak these.
  (symbol-translations nil)
  (thisify-classes (make-hash-table :test #'eq))
  (function-args (make-hash-table :test #'eq))
  (function-bodies (make-hash-table :test #'eq))
  (obfuscations (make-hash-table :test #'eq))
  plain-arg-funs
  (exported-closures nil)
  (delayed-var-inits nil)
  (rename-all-args? nil)
  (rename-toplevel-function-args? nil)
  (dot-expand? t)
  (raw-constructor-names? nil)
  (memorized-sources nil)
  (memorize-sources? t)

  (predefined-symbols nil)

  (global-funinfo nil)

  ; Literals that must be declared or cached before code with them is emitted.
  (compiled-chars (make-hash-table :test #'=))
  (compiled-numbers (make-hash-table :test #'=))
  (compiled-strings (make-hash-table :test #'eq))
  (compiled-symbols (make-hash-table :test #'eq))
  (compiled-decls nil)
  (compiled-inits nil)
  (emitted-decls nil)
  (imported-deps "")

  (raw-decls nil)

  ; Recompiling
  (sightened-files)
  (compiled-files)

  (current-package nil))

(defun transpiler-macro? (tr name)
  (or (expander-has-macro? (transpiler-std-macro-expander tr) name)
      (expander-has-macro? (transpiler-macro-expander tr) name)))

(defun transpiler-defined-functions (tr)
  (hashkeys (transpiler-defined-functions-hash tr)))

(defun transpiler-defined-function (tr name)
  (href (transpiler-defined-functions-hash tr) name))

(defun transpiler-defined-functions-without-builtins (tr)
  (remove-if #'builtin? (transpiler-defined-functions tr)))

(defun transpiler-add-defined-function (tr name)
  (setf (href (transpiler-defined-functions-hash tr) name) t)
  name)

(defun transpiler-defined-variable (tr name)
  (href (transpiler-defined-variables-hash tr) name))

(defun transpiler-add-defined-variable (tr name)
  (setf (href (transpiler-defined-variables-hash tr) name) t)
  name)

(defun transpiler-switch-obfuscator (tr on?)
  (setf (transpiler-obfuscate? tr) on?))

(defun transpiler-function-arguments (tr fun)
  (href (transpiler-function-args tr) fun))

(defun current-transpiler-function-arguments-w/o-builtins (x)
  (or (transpiler-function-arguments *current-transpiler* x)
	  (? (builtin? x)
		 'builtin
		 (function-arguments (symbol-function x)))))

(defun transpiler-function-body (tr fun)
  (href (transpiler-function-bodies tr) fun))

(defun transpiler-add-function-args (tr fun args)
  (setf (href (transpiler-function-args tr) fun) args))

(defun transpiler-add-function-body (tr fun args)
  (setf (href (transpiler-function-bodies tr) fun) args))

(define-slot-setter-push transpiler-add-unwanted-function tr
  (transpiler-unwanted-functions tr))

(defun transpiler-wanted-function? (tr fun)
  (href (transpiler-wanted-functions-hash tr) fun))

(defun transpiler-unwanted-function? (tr fun)
  (member fun (transpiler-unwanted-functions tr)))

(defun transpiler-wanted-variable? (tr name)
  (href (transpiler-wanted-variables-hash tr) name))

(defun transpiler-imported-variable? (tr x)
  (and (transpiler-import-from-environment? tr)
       (assoc x *variables* :test #'eq)))

(defun transpiler-inline-exception? (tr fun)
  (member fun (transpiler-inline-exceptions tr) :test #'eq))

(defun transpiler-cps-exception? (tr fun)
  (member fun (transpiler-cps-exceptions tr) :test #'eq))

(defun transpiler-cps-function? (tr fun)
  (member fun (transpiler-cps-functions tr) :test #'eq))

(define-slot-setter-push transpiler-add-inline-exception tr
  (transpiler-inline-exceptions tr))

(define-slot-setter-push transpiler-add-dont-inline tr
  (transpiler-dont-inline-list tr))

(define-slot-setter-push transpiler-add-cps-exception tr
  (transpiler-cps-exceptions tr))

(defun transpiler-add-obfuscation-exceptions (tr &rest x)
  (dolist (i x)
	(setf (href (transpiler-obfuscations tr) (make-symbol (symbol-name i)))
		  t)))

(define-slot-setter-push transpiler-add-plain-arg-fun tr
  (transpiler-plain-arg-funs tr))

(define-slot-setter-push transpiler-add-exported-closure tr
  (transpiler-exported-closures tr))

(define-slot-setter-push transpiler-add-cps-function tr
  (transpiler-cps-functions tr))

(defun transpiler-plain-arg-fun? (tr fun)
  (member fun (transpiler-plain-arg-funs tr) :test #'eq))

(defun transpiler-dont-inline? (tr fun)
  (member fun (transpiler-dont-inline-list tr) :test #'eq))

(defun transpiler-macro (tr name)
  (let expander (expander-get (transpiler-macro-expander tr))
    (funcall (expander-lookup expander)
			 expander
		     name)))

(defun transpiler-reset (tr)
  (setf (transpiler-thisify-classes tr) (make-hash-table :test #'eq)	; thisified classes.
  		(transpiler-wanted-functions tr) nil
  		(transpiler-wanted-functions-hash tr) (make-hash-table :test #'eq)
  		(transpiler-wanted-variables tr) nil
  		(transpiler-wanted-variables-hash tr) (make-hash-table :test #'eq)
  		(transpiler-defined-functions-hash tr) (make-hash-table :test #'eq)
  		(transpiler-defined-variables-hash tr) (make-hash-table :test #'eq)
  		(transpiler-function-args tr) (make-hash-table :test #'eq)
  		(transpiler-function-bodies tr) (make-hash-table :test #'eq)
  		(transpiler-exported-closures tr) nil
  		(transpiler-delayed-var-inits tr) nil
        (transpiler-memorized-sources tr) nil
        (transpiler-memorize-sources? tr) t)
  (transpiler-add-obfuscation-exceptions tr nil (make-symbol ""))
  tr)

(defun make-global-funinfo (tr)
  (make-lambda-funinfo (setf (transpiler-global-funinfo tr) (make-funinfo))))

(defun transpiler-package-symbol (tr x)
  (make-symbol (symbol-name x) (transpiler-current-package tr)))

(defun transpiler-emitted-decl? (tr x)
  (member x (transpiler-emitted-decls tr) :test #'eq))

(defun transpiler-add-emitted-decl (tr x)
  (push x (transpiler-emitted-decls tr)))

(def-transpiler copy-transpiler (transpiler)
  (aprog1
    (make-transpiler :name                   name
                     :std-macro-expander     std-macro-expander
                     :macro-expander         macro-expander
                     :setf-function?         setf-function?
                     :separator              separator
                     :unwanted-functions     unwanted-functions
                     :identifier-char?       identifier-char?
                     :literal-conversion     literal-conversion
                     :defined-functions-hash (copy-hash-table defined-functions-hash)
                     :defined-variables-hash (copy-hash-table defined-variables-hash)
                     :wanted-functions       (copy-list wanted-functions)
                     :wanted-functions-hash  (copy-hash-table wanted-functions-hash)
                     :wanted-variables       (copy-list wanted-variables)
                     :wanted-variables-hash  (copy-hash-table wanted-variables-hash)
                     :named-functions?       named-functions?
                     :named-function-next    named-function-next
                     :inline-exceptions      (copy-list inline-exceptions)
                     :dont-inline-list       (copy-list dont-inline-list)
                     :obfuscate?             obfuscate?
                     :import-from-environment? import-from-environment?
                     :save-sources?           save-sources?
                     :save-argument-defs-only? save-argument-defs-only?
                     :gen-string              gen-string
                     :lambda-export?          lambda-export?
                     :needs-var-declarations? needs-var-declarations?
                     :stack-locals?           stack-locals?
                     :place-expand-ignore-toplevel-funinfo? place-expand-ignore-toplevel-funinfo?
                     :apply-argdefs?          apply-argdefs?
                     :continuation-passing-style? continuation-passing-style?
                     :cps-exceptions          (copy-list cps-exceptions)
                     :cps-functions           (copy-list cps-functions)
                     :symbol-translations     (copy-list symbol-translations)
                     :thisify-classes         (copy-hash-table thisify-classes)
                     :function-args           (copy-hash-table function-args)
                     :function-bodies         (copy-hash-table function-args)
                     :obfuscations            (copy-hash-table obfuscations)
                     :plain-arg-funs          (copy-list plain-arg-funs)
                     :exported-closures       (copy-list exported-closures)
                     :delayed-var-inits       (copy-list delayed-var-inits)
                     :rename-all-args?        rename-all-args?
                     :rename-toplevel-function-args? rename-toplevel-function-args?
                     :dot-expand?             dot-expand?
                     :raw-constructor-names?  raw-constructor-names?
                     :memorized-sources       (copy-list memorized-sources)
                     :memorize-sources?       memorize-sources?
                     :predefined-symbols      (copy-list predefined-symbols)
                     :global-funinfo          (and global-funinfo (copy-funinfo global-funinfo))
                     :compiled-chars          (copy-hash-table compiled-chars)
                     :compiled-numbers        (copy-hash-table compiled-numbers)
                     :compiled-strings        (copy-hash-table compiled-strings)
                     :compiled-symbols        (copy-hash-table compiled-symbols)
                     :compiled-decls          (copy-list compiled-decls)
                     :compiled-inits          (copy-list compiled-inits)
                     :emitted-decls           (copy-list emitted-decls)
                     :imported-deps           imported-deps
                     :raw-decls               (copy-list raw-decls)
                     :sightened-files         (copy-alist sightened-files)
                     :compiled-files          (copy-alist compiled-files)
                     :current-package         current-package
                     :expex-initializer       expex-initializer)
    (funcall (transpiler-expex-initializer !) (transpiler-make-expex !))))
