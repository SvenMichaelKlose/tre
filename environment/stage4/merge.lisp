(fn merge (&rest x)
  (? (json-object? x.)
     (apply #'merge-props x)
     (!= nil
       (@ (x (apply #'append x) !)
         (adjoin! x !)))))
