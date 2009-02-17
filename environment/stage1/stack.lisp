;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (c) 2005-2008 Sven Klose <pixel@copei.de>
;;;;
;;;; Stack operations

(defmacro push (elm expr)
  "Destructively push element on front of list."
  `(setf ,expr (cons ,elm ,expr)))

(defmacro pop (expr)
  "Destructively pop element from front of list."
  `(let ret (car ,expr)
     (setf ,expr (cdr ,expr))
     ret))

(defun pop! (args)
  "Pop element from front of list and replaces cons register of first element
   by registers of the second."
  (let ret (car args)
    (setf (car args) (cadr args)
          (cdr args) (cddr args))
    ret))

(defmacro push! (value place)
  `(setf ,place (push ,value ,place)))
