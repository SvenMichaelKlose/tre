; tré – Copyright (c) 2008–2015 Sven Michael Klose <pixel@copei.de>

(defmacro define-shared-std-macro (targets &rest x)
  `(progn
     ,@(@ [`(,($ 'define- _ '-std-macro) ,@x)]
          (intersect *targets* (make-keywords targets)))))

(define-shared-std-macro (js php) defvar-native (&rest x)
  (print-definition `(defvar-native ,@x))
  (+! (predefined-symbols) x)
  (apply #'add-obfuscation-exceptions x)
  nil)

(define-shared-std-macro (js php) dont-obfuscate (&rest symbols)
  (apply #'add-obfuscation-exceptions symbols)
  nil)

(define-shared-std-macro (js php) declare-native-cps-function (&rest symbols)
  (print-definition `(declare-native-cps-function ,@symbols))
  (adolist symbols
    (add-native-cps-function !))
  nil)

(define-shared-std-macro (js php) declare-cps-exception (&rest symbols)
  (print-definition `(declare-cps-exception ,@symbols))
  (adolist symbols
    (add-cps-exception !))
  nil)

(define-shared-std-macro (js php) declare-cps-wrapper (&rest symbols)
  (print-definition `(declare-cps-wrapper ,@symbols))
  (adolist symbols
    (add-cps-wrapper !))
  nil)

(define-shared-std-macro (js php) assert (x &optional (txt nil) &rest args)
  (& (assert?)
     (make-assertion x txt args)))

(define-shared-std-macro (js php) functional (&rest x)
  (print-definition `(functional ,@x))
  (adolist x
    (? (transpiler-functional? *transpiler* !)
       (warn "Redefinition of functional ~A." !))
    (add-functional !))
  nil)

(define-shared-std-macro (c js php) not (&rest x)
   `(? ,x. nil ,(!? .x
                    `(not ,@!)
                    t)))

(define-shared-std-macro (bc c js php) mapcar (fun &rest lsts)
  `(,(? .lsts
        'mapcar
        'filter)
        ,fun ,@lsts))

(define-shared-std-macro (bc c js php) defmacro (name args &body body)
  (print-definition `(defmacro ,name ,args))
  (make-transpiler-std-macro name args body)
  `(%defmacro ,name ,args ,@body))

(define-shared-std-macro (bc c js php) defconstant (&rest x)
  `(defvar ,@x))

(define-shared-std-macro (bc c js php) defvar (name &optional (val '%%no-value))
  (& (eq '%%no-value val)
     (= val `',name))
  (print-definition `(defvar ,name))
  (& (defined-variable name)
     (redef-warn "Redefinition of variable ~A.~%" name))
  (add-defined-variable name)
  (& *have-compiler?*
     (add-delayed-var-init `((= *variables* (. (. ',name ',val) *variables*)))))
  `(progn
     ,@(& (needs-var-declarations?)
          `((%var ,name)))
     (%= ,name ,val)))
