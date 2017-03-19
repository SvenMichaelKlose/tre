(fn object? (x)
  (is_object x))

(fn pure-object? (x)
  (& (not (array? x))
     (is_array x)))
