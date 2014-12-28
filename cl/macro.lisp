;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(in-package :tre-core)

(defvar *macros* nil)

(defun macro? (x)
  (rassoc x *macros* :test #'eq))

(defmacro %defmacro (name args &body body)
  (print `(%defmacro ,name ,args))
  `(push (cons ',name
               (cons ',args
                     #'(lambda ,(argument-expand-names '%defmacro args)
                         ,@body)))
         *macros*))

(defun %%macrocall (x)
  (alet (cdr (assoc (car x) *macros* :test #'eq))
    (apply (cdr !) (cdrlist (argument-expand (car x) (car !) (cdr x))))))

(defun %%macro? (x)
  (and (consp x)
       (symbolp (car x))
       (assoc (car x) *macros* :test #'eq)))

(defun %equal (a b) (equal a b))
