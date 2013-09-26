;;;;; tré – Copyright (c) 2009–2013 Sven Michael Klose <pixel@copei.de>

(defun count-tags (x)
  (& (named-lambda? x.)
     (alet (lambda-body x.)
       (= (funinfo-num-tags (get-lambda-funinfo x.)) (count-if #'number? !))
       (count-tags !)))
   (& x (count-tags .x)))
