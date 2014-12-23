;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(defvar *macros* nil)

(defun macro? (x) (cl:rassoc x *macros* :test #'eq))

(defmacro %defmacro (name args &body body)
  (print `(%defmacro ,name ,args))
  `(push (. ',name
            (. ',args
               #'(lambda ,(argument-expand-names '%defmacro args)
                   ,@body)))
         *macros*))

(defun %%macrocall (x)
  (alet (cdr (cl:assoc x. *macros* :test #'eq))
    (cl:apply .! (cdrlist (argument-expand x. !. .x)))))

(defun %%%macro? (x)
  (assoc x *macros* :test #'eq))

(defvar *macroexpand-hook* nil)                                                                                                                              

(defun macroexpand-1 (x)
  (? *macroexpand-hook*
     (apply *macroexpand-hook* (list x))
     x))

(defun macroexpand-0 (old x)
  (? (%equal x old)
     old
     (macroexpand x)))

(defun macroexpand (x)
  (macroexpand-0 x (macroexpand-1 x)))
