;;;;; tré - Copyright (c) 2012–2013 Sven Michael Klose <pixel@copei.de>

(defun trim-crlf (x)
  (let len (-- (length x))
    (? (< (elt x len) 33)
       (trim-crlf (subseq x 0 len))
       x)))
