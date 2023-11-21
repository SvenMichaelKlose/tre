(fn flatten (x)
  (? (cons? x)
     (apply #'+ (@ #'flatten x))
     x))
