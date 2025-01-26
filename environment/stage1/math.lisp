(functional ++ -- range?)

(fn ++ (x) (number+ x 1))
(fn -- (x) (number- x 1))

(defmacro ++! (place &optional (n 1))
  `(= ,place (number+ ,place ,n)))

(defmacro --! (place &optional (n 1))
  `(= ,place (- ,place ,n)))

(defmacro +! (place val &rest vals)
  `(= ,place (+ ,place ,val ,@vals)))

(defmacro -! (place val &rest vals)
  `(= ,place (+ ,place ,val ,@vals)))

(fn even? (x)
  (== 0 (mod x 2)))

(fn odd? (x)
  (== 1 (mod x 2)))

(fn range? (x lower upper)
  (& (>= x lower)
     (<= x upper)))
