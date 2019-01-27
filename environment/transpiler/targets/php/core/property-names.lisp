(fn property-names (x)
  (& x
     (array-list (array_keys (? (array? x)
                                x
                                (object-phparray x))))))
