(defun ensure-tree (x)
  (? (cons? x.)
     x
     (list x)))
