(fn min (&rest x)
  (& x
     (? .x
        (? (< x. .x.)
           (apply #'min x. ..x)
           (apply #'min .x))
        x.)))
