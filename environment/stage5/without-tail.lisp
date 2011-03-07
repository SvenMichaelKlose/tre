;;;;; TRE environment
;;;;; Copyright (c) 2011 Sven Klose <pixel@copei.de>

(defun without-tail (x tail)
  (? (ends-with? x tail)
     (subseq x 0 (- (length x) (length tail)))
     x))
