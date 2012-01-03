;;;;; tré - Copyright (c) 2012 Sven Michael Klose <pixel@copei.de>

(defun trim-crlf (x)
  (let len (1- (length x))
    (? (< (elt x len) 33)
       (trim-crlf (subseq x 0 len))
       x)))
