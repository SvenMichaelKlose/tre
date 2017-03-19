(fn object? (x)
  (is_object x))

(fn assoc-array? (x)
  (& (not (array? x))
     (is_array x)
     (is_int (key x))))
