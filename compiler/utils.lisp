;;;; nix operating system project
;;;; lisp compiler
;;;; Copyright (C) 2005-2008 Sven Klose <pixel@copei.de>
;;;;
;;;; Miscellaneous utilities.

(defun enqueue-many (q l)
  (dolist (e l)
    (enqueue q e)))

(defmacro with-cons (a d c &rest body)
  `(let ((,a (car ,c))
         (,d (cdr ,c)))
     ,@body))

(defun print-symbols (forms)
  (dolist (i forms)
    (verbose " ~A" (symbol-name i))))

(defmacro t? (x)
  `(eq t ,x))

(defun assoc-splice (x)
  (values (carlist x) (cdrlist x)))
