(defmacro define-shared-std-macro (targets &rest x)
  `{,@(@ [`(,($ 'define- _ '-std-macro) ,@x)]
         (intersect *targets* (make-keywords targets)))})

(define-shared-std-macro (js php) dont-obfuscate (&rest symbols)
  (apply #'add-obfuscation-exceptions symbols)
  nil)

(define-shared-std-macro (js php) defvar-native (&rest x)
  (print-definition `(defvar-native ,@x))
  (+! (predefined-symbols) x)
  nil)

(define-shared-std-macro (js php) assert (x &optional (txt nil) &rest args)
  (& (assert?)
     (make-assertion x txt args)))

(define-shared-std-macro (js php) functional (&rest x)
  (print-definition `(functional ,@x))
  (@ (i x)
;    (? (transpiler-functional? *transpiler* !)
;       (warn "Redefinition of functional ~A." !))
    (transpiler-add-functional *transpiler* i))
  nil)

(define-shared-std-macro (c js php) not (&rest x)
   `(? ,x. nil ,(!? .x
                    `(not ,@!)
                    t)))

(define-shared-std-macro (bc c js php) defmacro (name args &body body)
  (print-definition `(defmacro ,name ,args))
  (make-transpiler-std-macro name args (macroexpand body))
  `(%defmacro ,name ,args ,@body))

(define-shared-std-macro (bc c js php) defconstant (&rest x)
  `(var ,@x))

(define-shared-std-macro (bc c js php) defvar (name &optional (val '%%no-value-in-defvar))
  (& (eq '%%no-value val)
     (= val `',name))
  (print-definition `(var ,name))
  (& (defined-variable name)
     (redef-warn "Redefinition of variable ~A.~%" name))
  (add-defined-variable name)
  (& *have-compiler?*
     (add-delayed-expr `((= *variables* (. (. ',name ',val) *variables*)))))
  `{,@(& (needs-var-declarations?)
         `((%var ,name)))
    (%= ,name ,val)})

(define-shared-std-macro (bc c js php) %defvar (name &optional (val '%%no-value-in-%defvar))
  `(var ,name ,val))

(define-shared-std-macro (bc c js php) in-package (name &optional (val '%%no-value-in-in-package))
  (cl:eval `(cl:in-package ,(symbol-name name)))
  (= *package* name)
  nil)

(define-shared-std-macro (bc c js php) defpackage (&rest x)
  (cl:eval `(cl:defpackage ,@x))
  nil)

(define-shared-std-macro (bc c js php) mapcar (fun &rest lsts)
  `(,(? .lsts
        'mapcar
        'filter)
        ,fun ,@lsts))
