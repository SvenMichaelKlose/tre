(fn get-angle (x1 y1 x2 y2)
  (/ (* 180 (atan2 (- y2 y1) (- x2 x1))) *pi*))
