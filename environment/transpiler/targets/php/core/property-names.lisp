(fn property-names (x)
  (& x
     (array-list (array_keys (? (object? x)
                                (get_object_vars x)
                                x)))))
