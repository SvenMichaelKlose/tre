;;;;; tré – Copyright (c) 2009,2012,2014 Sven Michael Klose <pixel@copei.de>

(defun tail? (x tail &key (test #'equal))
  (with (xlen  (length x)
         tlen  (length tail))
    (unless (< xlen tlen)
      (funcall test tail (subseq x (- xlen tlen))))))
