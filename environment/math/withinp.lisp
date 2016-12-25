(defun within? (x lower interval)
  (& (<= lower x)
     (< x (+ lower interval))))
