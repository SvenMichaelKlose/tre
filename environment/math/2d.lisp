(fn distance (x y x2 y2)
  (sqrt (+ (pow (abs (- x x2)) 2)
           (pow (abs (- y y2)) 2))))

(fn inside-rect? (x y rx ry rw rh)
  (& (within? x rx rw) 
     (within? y ry rh)))

(fn clip-axis (p lower upper)
  (? (< p lower)
     (- p lower)
     (? (> p upper)
        (- p upper)
        0)))
