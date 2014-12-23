;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(defun not (&rest x) (cl:every #'cl:not x))
(defun builtin? (x)   (cl:gethash x *builtins*))

(defun variable-compare (predicate x)
  (? .x
     (alet x.
       (dolist (i .x t)
         (| (funcall predicate ! i)
            (return nil))))
     (cl:error "At least 2 arguments required.")))

(defun eq (x) (variable-compare #'cl:eq x))
(defun eql (x) (variable-compare #'cl:eql x))
