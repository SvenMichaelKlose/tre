(fn merge (&rest x)
  (!= nil
    (@ (x (apply #'append x) !)
      (adjoin! x !))))
