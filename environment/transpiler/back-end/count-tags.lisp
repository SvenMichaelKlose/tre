;;;;; tré – Copyright (c) 2009–2013 Sven Michael Klose <pixel@copei.de>

(defun count-tags-r (x)
  (& (named-lambda? x.)
     (alet (lambda-body x.)
       (= (funinfo-num-tags (get-lambda-funinfo x.)) (count-if #'number? !))
       (count-tags-r !)))
   (& x (count-tags-r .x)))

(defun count-tags (x)
  (& (transpiler-count-tags? *transpiler*)
     (count-tags-r x))
  x)
