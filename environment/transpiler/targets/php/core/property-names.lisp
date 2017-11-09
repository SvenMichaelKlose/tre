(fn property-names (x)
  (& x
     (array-list (array_keys (get_object_vars x)))))
