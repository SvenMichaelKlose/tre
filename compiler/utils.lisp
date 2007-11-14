;;;; nix operating system project
;;;; lisp compiler
;;;; Copyright (C) 2005-2007 Sven Klose <pixel@copei.de>
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

(defun group (l size)
  (when l
    (cons (subseq l 0 size) (group (subseq l size) size))))

(defmacro t? (x)
  `(eq t ,x))
