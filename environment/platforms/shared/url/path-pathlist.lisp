(defun path-pathlist (x)
  (split #\/ x))

(defun pathlist-path (x)
  (? x
     (apply #'string-concat (pad x "/"))
     ""))
