(fn object? (x)
  (is_object x))

(fn assoc-array? (x)
  (& (is_array x)
     (is_string (key x))))
