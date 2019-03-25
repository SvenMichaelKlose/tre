(fn merge (&rest x)
  (alet nil
    (@ (x (apply #'append x) !)
      (adjoin! x !))))
