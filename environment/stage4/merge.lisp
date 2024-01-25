(fn merge (&rest x)
  (? (json-object? x.)
     (*> #'merge-props x)
     (!= nil
       (@ (x (*> #'append x) !)
         (adjoin! x !)))))
