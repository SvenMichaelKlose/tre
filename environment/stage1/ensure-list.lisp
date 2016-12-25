(functional ensure-list)

(defun ensure-list (x)
  (? (list? x)
     x
     (list x)))
