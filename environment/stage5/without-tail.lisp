;;;;; tré – Copyright (c) 2011,2014 Sven Michael Klose <pixel@copei.de>

(defun without-tail (x tail)
  (? (tail? x tail)
     (subseq x 0 (- (length x) (length tail)))
     x))
