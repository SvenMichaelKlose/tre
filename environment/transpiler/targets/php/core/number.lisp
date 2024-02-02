(fn integer? (x)
  (is_int x))

(fn number? (x)
  (| (is_int x)
     (is_float x)))

(fn number (x)
  (%native "(float)$" x))

(fn number-integer (x)
  (%native "(int)$" x))
