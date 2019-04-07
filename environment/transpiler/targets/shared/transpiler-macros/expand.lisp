(defmacro define-shared-transpiler-macro (targets &rest x)
  `{,@(@ [`(,($ 'def- _ '-transpiler-macro) ,@x)]
         (intersect *targets* (make-keywords targets)))})

(define-shared-transpiler-macro (js php) assert (x &optional (txt nil) &rest args)
  (& (assert?)
     (make-assertion x txt args)))

(define-shared-transpiler-macro (js php) functional (&rest x)
  (print-definition `(functional ,@x))
  (@ (i x)
    (? (transpiler-functional? *transpiler* i)
       (warn "FUNCTIONAL: Already declared ~A as being a pure function." i))
    (transpiler-add-functional *transpiler* i))
  nil)

(define-shared-transpiler-macro (c js php) not (&rest x)
  `(? ,x.
      nil
      ,(? .x
          `(not ,@.x)
          t)))

(define-shared-transpiler-macro (bc c js php) defmacro (name args &body body)
  (print-definition `(defmacro ,name ,args))
  (make-transpiler-macro name args (macroexpand body))
  `(%defmacro ,name ,args ,@body))

(define-shared-transpiler-macro (bc c js php) defconstant (&rest x)
  `(var ,@x))

(define-shared-transpiler-macro (bc c js php) defvar (name &optional (val '%%no-value-in-defvar))
  (& (eq '%%no-value val)
     (= val `',name))
  (print-definition `(var ,name))
  (& (defined-variable name)
     (warn "Redefinition of variable ~A." name))
  (add-defined-variable name)
  (& *have-compiler?*
     (add-delayed-expr `((= *variables* (. (. ',name ',val) *variables*)))))
  `{,@(& (needs-var-declarations?)
         `((%var ,name)))
    (%= ,name ,val)})

(define-shared-transpiler-macro (bc c js php) %defvar (name &optional (val '%%no-value-in-%defvar))
  `(var ,name ,val))

(define-shared-transpiler-macro (bc c js php) in-package (name &optional (val '%%no-value-in-in-package))
  (cl:eval `(cl:in-package ,(symbol-name name)))
  (= *package* name)
  nil)

(define-shared-transpiler-macro (bc c js php) defpackage (&rest x)
  (cl:eval `(cl:defpackage ,@x))
  nil)

(define-shared-transpiler-macro (js php) new (&rest x)
  (? (| (not x)
        (keyword? x.)
        (string? x.))
     `(%%%make-object ,@x)
     `(%new ,@x)))

(define-shared-transpiler-macro (bc c js php) mapcar (fun &rest lsts)
  `(,(? .lsts
        'mapcar
        'filter)
        ,fun ,@lsts))

(define-shared-transpiler-macro (js php) string-concat (&rest x)
  `(%%%string+ ,@x))

(define-shared-transpiler-macro (js php) eq (&rest x)   ; TODO: There's another macro to do this.
  (? ..x
     `(& (eq ,x. ,.x.)
         (eq ,x. ,@..x))
     `(eq ,@x)))
