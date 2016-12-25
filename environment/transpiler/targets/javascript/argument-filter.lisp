(defun js-argument-filter (x)
  (? (global-literal-function? x)
     .x.
     x))
