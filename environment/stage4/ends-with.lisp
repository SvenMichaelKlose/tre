;;;;; TRE environment
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defun ends-with (x tail)
  (let s (force-string x)
    (string= tail (subseq s (- (length s)
							   (length tail))))))
