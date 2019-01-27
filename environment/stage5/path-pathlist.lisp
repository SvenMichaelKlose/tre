(fn path-pathlist (x)
  (split #\/ x))

(fn pathlist-path (x)
  (? x
     (apply #'string-concat (pad x "/"))
     ""))
