(fn make-object (&rest x)
  (!= (*> #'make-json-object x)
    (%native "(object)$" !)))

(fn object? (x)
  (is_object x))

(fn json-object? (x)
  (is_a x "stdClass"))
