; tré – Copyright (c) 2014–2015 Sven Michael Klose <pixel@hugbox.org>

(defbuiltin not (&rest x) (cl:every #'cl:not x))
(defbuiltin builtin? (x)  (cl:gethash x *builtins*))

(defun variable-compare (predicate x)
  (? .x
     (@ (i .x t)
       (| (funcall predicate x. i)
          (return nil)))
     (cl:error "At least 2 arguments required.")))

(defun non-keyword-symbol? (x)
  (& (cl:symbolp x)
     (cl:not (cl:keywordp x))))

(defun xpackeq (a b)
  (? (& (non-keyword-symbol? a)
        (non-keyword-symbol? b))
     (cl:string= (cl:symbol-name a)
                 (cl:symbol-name b))
     (cl:eq a b)))

(defun tre-eql (a b)
  (?
    (& (number? a)
       (number? b))   (& (cl:eq (cl:characterp a)
                                (cl:characterp b))
                         (== a b))
    (& (cl:consp a)
       (cl:consp b))  (& (tre-eql a. b.)
                         (tre-eql .a .b))
    (xpackeq a b)))

(defbuiltin eq (&rest x)  (variable-compare #'xpackeq x))
(defbuiltin eql (&rest x) (variable-compare #'tre-eql x))
