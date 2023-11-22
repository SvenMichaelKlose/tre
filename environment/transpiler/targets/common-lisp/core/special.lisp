(var *special-forms* nil)

(fn special-%%macrocall (x)
  (!= (cdr (assoc x. *special-forms* :test #'eq))
    (apply .! (argument-expand-values x. !. .x))))

(fn special-%%macro? (x)
  (& (cons? x)
     (symbol? x.)
     (assoc x. *special-forms* :test #'eq)))

(fn specialexpand (x)
  (with-temporaries (*macro?*     #'special-%%macro?
                     *macrocall*  #'special-%%macrocall)
    (with (f #'((old x)
                 (? (equal old x)
                    x
                    (f x (%macroexpand x)))))
      (f x (%macroexpand x)))))

(fn make-%fn-quiet (name args body)
  (? args
     (ensure-list! args))
  `(CL:PROGN
     (CL:PUSH (. ',name ',(. args body)) *functions*)
     (CL:DEFUN ,name ,args ,@body)))

(defspecial %fn-quiet (name args &body body)
  (make-%fn-quiet name args body))

(defspecial %fn (name args &body body)
  (print-definition `(%fn ,name ,args))
  (make-%fn-quiet name args body))

(defspecial %defmacro (name args &body body)
  (print-definition `(%defmacro ,name ,args))
  `(CL:PUSH (. ',name
               (. ',(. args body)
                  #'(,(argument-expand-names '%defmacro args)
                    ,@body)))
            ,(tre-symbol '*macros*)))

(defspecial %defvar (name &optional (init nil))
  (print-definition `(%defvar ,name))
  `(progn
     (CL:PUSH (. ',name ',init) *variables*)
     (CL:DEFVAR ,name ,init)))

(defspecial ? (&body body)
  (make-? body))
