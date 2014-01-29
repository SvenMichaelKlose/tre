;;;;; tré – Copyright (c) 2011,2014 Sven Michael Klose <pixel@copei.de>

(defun without-head (x head)
  (? (head? x head)
     (subseq x (length head))
     x))
