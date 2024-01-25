(fn flatten (x)
  (? (cons? x)
     (*> #'+ (@ #'flatten x))
     x))
