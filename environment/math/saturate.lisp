(fn saturates? (x y max)
  (> (+ x y) max))

(fn saturate (x y max)
  (? (saturates? x y max)
     max
     (+ x y)))

(fn desaturates? (x y &optional (min 0))
  (< (- x y) min))

(fn desaturate (x y &optional (min 0))
  (? (desaturates? x y min)
     min
     (- x y)))

(defmacro saturate! (place x max)
  `(= ,place (saturate ,place ,x ,max)))

(defmacro desaturate! (place x &optional (min 0))
  `(= ,place (desaturate ,place ,x ,min)))
