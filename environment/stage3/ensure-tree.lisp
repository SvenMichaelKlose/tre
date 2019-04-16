(functional ensure-tree)

(fn ensure-tree (x)
  (? (cons? x.)
     x
     (list x)))
