;;;;; tré - Copyright (c) 2009,2012 Sven Michael Klose <pixel@copei.de>

(defun remove-tail (x tail)
  (? (ends-with? x tail)
     (subseq x 0 (integer- (length x) (length tail)))
     x))
