; tré – Copyright (c) 2014–2015 Sven Michael Klose <pixel@hugbox.org>

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

(defun tre-eql (a b)
  (? (& (number? a)
        (number? b))
     (? (eq (character? a)
            (character? b))
        (== a b))
     (& (cons? a)
        (cons? b)) (& (tre-eql a. b.)
                      (tre-eql .a .b))
     (xpackeq a b)))

(defbuiltin eq (&rest x) (variable-compare #'xpackeq x))
(defbuiltin eql (&rest x) (variable-compare #'tre-eql x))
