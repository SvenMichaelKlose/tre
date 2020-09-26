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
     (= args (? (cons? args)
                args
                (list args))))
  `(cl:progn
     (cl:push (. ',name ',(. args body)) *functions*)
     (cl:defun ,name ,args ,@body)))

(defspecial %fn-quiet (name args &body body)
  (make-%fn-quiet name args body))

(defspecial %fn (name args &body body)
  (print-definition `(%fn ,name ,args))
  (make-%fn-quiet name args body))

(defspecial %defmacro (name args &body body)
  (print-definition `(%defmacro ,name ,args))
  `(cl:push (. ',name
               (. ',(. args body)
                  #'(,(argument-expand-names '%defmacro args)
                    ,@body)))
            ,(tre-symbol '*macros*)))

(defspecial %defvar (name &optional (init nil))
  (print-definition `(%defvar ,name))
  `(progn
     (cl:push (. ',name ',init) *variables*)
     (cl:defvar ,name ,init)))

(defspecial ? (&body body)            (make-? body))
