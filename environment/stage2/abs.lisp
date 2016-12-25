(functional abs)

(defun abs (x)
  (? (< x 0)
     (- x)
     x))
