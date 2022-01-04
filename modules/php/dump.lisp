(var *standard-log* *standard-output*)

(fn dump (x &optional (title nil))
  (& title
     (error_log title))
  (error_log x)
  x)
