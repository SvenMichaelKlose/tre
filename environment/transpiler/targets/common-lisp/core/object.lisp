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

(defun xpackeq (a b)
  (? (& (symbol? a)
        (symbol? b)
        (not (keyword? a)
             (keyword? b)))
     (cl:string= (symbol-name a)
                 (symbol-name b))
     (cl:eq a b)))

(defbuiltin eq (&rest x) (variable-compare #'xpackeq x))
(defbuiltin eql (&rest x) (variable-compare #'cl:eql x))
