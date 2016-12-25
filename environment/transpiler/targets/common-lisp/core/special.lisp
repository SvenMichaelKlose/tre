(defvar *special-forms* nil)

(defun special-%%macrocall (x)
  (alet (cdr (assoc x. *special-forms* :test #'eq))
    (apply .! (argument-expand-values x. !. .x))))

(defun special-%%macro? (x)
  (& (cons? x)
     (symbol? x.)
     (assoc x. *special-forms* :test #'eq)))

(defun specialexpand (x)
  (with-temporaries (*macro?*     #'special-%%macro?
                     *macrocall*  #'special-%%macrocall)
    (with (f #'((old x)
                 (? (equal old x)
                    x
                    (f x (%macroexpand x)))))
      (f x (%macroexpand x)))))

(defun make-%defun-quiet (name args body)
  `(cl:progn
     (cl:push (. ',name ',(. args body)) *functions*)
     (cl:defun ,name ,args ,@body)))

(defspecial %defun-quiet (name args &body body)
  (make-%defun-quiet name args body))

(defspecial %defun (name args &body body)
  (print-definition `(%defun ,name ,args))
  (make-%defun-quiet name args body))

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
