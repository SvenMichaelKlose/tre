(fn keys (x)
  (& x
     (array-list (array_keys (? (array? x)
                                x
                                (object-phparray x))))))
