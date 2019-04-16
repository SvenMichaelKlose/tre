(js-type-predicate number? "number")

(fn number (x)
  (parse-float x 10))

(functional string-integer)
(fn string-integer (x)
  (parse-int x 10))

(functional number-integer)
(fn number-integer (x)
  (*math.floor x))

(fn integer? (x)
  (& (number? x)
     (%%%== (parse-int x 10) (parse-float x 10))))
