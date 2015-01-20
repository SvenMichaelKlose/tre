; tré – Copyright (c) 2014–2015 Sven Michael Klose <pixel@copei.de>

(defun special-%%macrocall (x)
  (alet (cdr (assoc x. *macros* :test #'eq))
    (apply .! (argument-expand-values x. !. .x))))

(defun special-%%macro? (x)
  (& (cons? x)
     (symbol? x.)
     (assoc x. *macros* :test #'eq)))

(defun specialexpand (x)
  (with-temporaries (*macro?-diversion*    #'special-%%macro?
                     *macrocall-diversion* #'special-%%macrocall)
    (with (f #'((old x)
                 (? (equal old x)
                    x
                    (specialexpand x))))
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
               (. ',args
                  #'(,(argument-expand-names '%defmacro args)
                    ,@body)))
            ,(make-symbol "*MACROS*" "TRE")))

(defspecial %defvar (name &optional (init nil))
  (print-definition `(%defvar ,name))
  `(cl:defvar ,name ,init))

(defspecial setq (&body body) `(cl:setq ,@body))
(defspecial cond (&body body) `(cl:cond ,@body))
(defspecial progn (&body body) `(cl:progn ,@body))
(defspecial block (&body body) `(cl:block ,@body))
(defspecial return-from (&body body) `(cl:return-from ,@body))
(defspecial tagbody (&body body) `(cl:tagbody ,@body))
(defspecial go (&body body) `(cl:go ,@body))
;(defspecial function (&body body) `(cl:function ,@body))
(defspecial labels (&body body) `(cl:labels ,@body))
(defspecial ? (&body body) (make-? body))
