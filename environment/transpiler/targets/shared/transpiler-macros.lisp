(defmacro def-shared-transpiler-macro (targets &rest x) ; TODO: Complain if re-defined.
  `(progn
     ,@(@ [`(,($ 'def- _ '-transpiler-macro) ,@x)]
     (intersect *targets* (make-keywords targets)))))

(def-shared-transpiler-macro (js php) assert (x &optional (txt nil) &rest args)
  (& (assert?)
     (make-assertion x txt args)))

(def-shared-transpiler-macro (js php) functional (&rest x)
  (print-definition `(functional ,@x))
  (@ (i x)
    (| (transpiler-functional? *transpiler* i)
       (transpiler-add-functional *transpiler* i)))
  nil)

(def-shared-transpiler-macro (c js php) not (&rest x)
  `(? ,x.
      nil
      ,(? .x
          `(not ,@.x)
          t)))

(def-shared-transpiler-macro (bc c js php) defmacro (name args &body body)
  (print-definition `(defmacro ,name ,args))
  (make-transpiler-macro name args (macroexpand body))
  `(%defmacro ,name ,args ,@body))

(def-shared-transpiler-macro (bc c js php) defconstant (&rest x)
  `(var ,@x))

(def-shared-transpiler-macro (bc c js php) defvar (name &optional (val '%%no-value-in-defvar))
  (when (eq '%%no-value val)
    (= val `',name))
  (print-definition `(var ,name))
  (when (defined-variable name)
    (warn "Redefinition of variable ~A." name))
  (add-defined-variable name)
  (when *have-compiler?*
    (+! (delayed-exprs)
        (frontend `((= *variables* (. (. ',name ',val) *variables*))))))
  `(progn
     ,@(when (needs-var-declarations?)
         `((%var ,name)))
     (%= ,name ,val)))

; TODO: What? (pixel)
(def-shared-transpiler-macro (bc c js php) %defvar
                             (name &optional (val '%%no-value-in-%defvar))
  `(var ,name ,val))

(def-shared-transpiler-macro (js php) new (&rest x)
  `(%new ,@x))

(def-shared-transpiler-macro (bc c js php) mapcar (fun &rest lsts)
  `(,(? .lsts
        'mapcar
        'filter)
        ,fun ,@lsts))

(def-shared-transpiler-macro (js php) string-concat (&rest x)
  `(%string+ ,@x))

(def-shared-transpiler-macro (js php) eq (&rest x)
  ; TODO: Should expand to %EQs. (pixel)
  (? ..x
     `(& (eq ,x. ,.x.)
         (eq ,x. ,@..x))
     `(eq ,@x)))

(def-shared-transpiler-macro (js php) defpackage (name &rest options)
  (print-definition `(defpackage ,name ,@options))
  (cl:eval `(cl:defpackage ,name ,@options))
  nil)

(def-shared-transpiler-macro (js php) in-package (name)
  (print-definition `(in-package ,name))
  (= *package* (symbol-name name))
  nil)

(def-shared-transpiler-macro (bc c js php) labels (fdefs &body body)
  `(#'(,(carlist fdefs)
        ,@(@ [`(%set-local-fun ,_. 
                   #'(,._.
                       (block ,_.
                         (block nil
                           ,@.._))))]
             fdefs)
      ,@body)
    ,@(@ [] fdefs)))

(def-shared-transpiler-macro (js php) slot-value (obj slot)
  (? (quote? slot)
     `(%slot-value ,obj ,.slot.)
     `(slot-value ,obj ,slot)))

(def-shared-transpiler-macro (js php) =-slot-value (val obj slot)
  (? (quote? slot)
     `(%=-slot-value ,val ,obj ,.slot.)
     `(=-slot-value ,val ,obj ,slot)))
