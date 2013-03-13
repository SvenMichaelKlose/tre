;;;;; Caroshi – Copyright (c) 2008–2009,2011–2013 Sven Michael Klose <pixel@copei.de>

(defun distance (x y x2 y2)
  (sqrt (+ (pow (abs (- x x2)) 2)
           (pow (abs (- y y2)) 2))))

(defun inside-rect? (x y rx ry rw rh)
  (& (within? x rx rw) 
     (within? y ry rh)))

(defun clip-axis (p lower upper)
  (? (< p lower)
     (- p lower)
     (? (> p upper)
        (- p upper)
        0)))
