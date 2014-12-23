; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(defbuiltin not (&rest x) (cl:every #'cl:not x))
(defbuiltin builtin? (x)   (cl:gethash x *builtins*))

(defun variable-compare (predicate x)
  (? .x
     (alet x.
       (dolist (i .x t)
         (| (funcall predicate ! i)
            (return nil))))
     (cl:error "At least 2 arguments required.")))

(defbuiltin eq (x) (variable-compare #'cl:eq x))
(defbuiltin eql (x) (variable-compare #'cl:eql x))
