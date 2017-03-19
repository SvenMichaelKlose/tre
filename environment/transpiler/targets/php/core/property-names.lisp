(fn property-names (x)
  (array-list (array_keys (? (object? x)
                             (get_object_vars x)
                             x))))
