(functional range?)

(defun range? (x bottom top)
  (& (>= x bottom)
     (<= x top)))
