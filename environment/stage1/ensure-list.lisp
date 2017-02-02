(functional ensure-list)

(fn ensure-list (x)
  (? (list? x)
     x
     (list x)))
