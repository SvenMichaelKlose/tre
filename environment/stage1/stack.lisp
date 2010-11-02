;;;; TRE environment
;;;; Copyright (c) 2005-2008 Sven Klose <pixel@copei.de>

(defmacro push (elm expr)
  `(setf ,expr (cons ,elm ,expr)))

(defmacro pop (expr)
  `(let ret (car ,expr)
     (setf ,expr (cdr ,expr))
     ret))

(defun pop! (args)
  (let ret (car args)
    (setf (car args) (cadr args)
          (cdr args) (cddr args))
    ret))

(defmacro push! (value place)
  `(setf ,place (push ,value ,place)))
