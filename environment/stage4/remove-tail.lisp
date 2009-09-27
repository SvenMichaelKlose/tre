;;;;; TRE environment
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defun remove-tail (x tail)
  (if (ends-with? x tail)
      (subseq x 0 (- (length x)
                     (length tail)))
      x))
