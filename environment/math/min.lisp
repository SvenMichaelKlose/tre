(fn min (&rest x)
  (& x
     (? .x
        (? (< x. .x.)
           (*> #'min x. ..x)
           (*> #'min .x))
        x.)))
