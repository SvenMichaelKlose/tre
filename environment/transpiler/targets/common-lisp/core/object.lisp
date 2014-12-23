;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(in-package :tre-core)

(defun %not (&rest x) (every #'not x))
(defun builtin? (x) (gethash x *builtins*))

(defun variable-compare (predicate x)
  (? (cdr x)
     (alet (car x)
       (dolist (i (cdr x) t)
         (or (funcall predicate ! i)
             (return nil))))
     (error "At least 2 arguments required.")))

(defun %eq (x) (variable-compare #'eq x))
(defun %eql (x) (variable-compare #'eql x))
