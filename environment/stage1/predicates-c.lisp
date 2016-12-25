(defun integer? (x)
  (& (number? x)
     (== 0 (mod x 1))))
