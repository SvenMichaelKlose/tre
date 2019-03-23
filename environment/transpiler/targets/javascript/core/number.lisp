(js-type-predicate number? "number")

(fn number (x)
  (parse-float x 10))

(fn string-integer (x)
  (parse-int x 10))

(fn number-integer (x)
  (*math.floor x))

(fn integer? (x)
  (& (number? x)
     (%%%== (parse-int x 10) (parse-float x 10))))
