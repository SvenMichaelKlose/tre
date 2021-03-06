(fn zero? (x)
  (& (number? x)
     (== 0 x)))

(fn even? (x)
  (== 0 (mod x 2)))

(fn odd? (x)
  (== 1 (mod x 2)))

(functional ++ --)

(fn ++ (x) (number+ x 1))
(fn -- (x) (number- x 1))

(defmacro ++! (place &optional (n 1))
  `(= ,place (number+ ,place ,n)))

(defmacro --! (place &optional (n 1))
  `(= ,place (- ,place ,n)))
