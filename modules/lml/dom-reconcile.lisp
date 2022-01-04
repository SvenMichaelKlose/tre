(fn dom-reconcile (a b)
  (when (a.has-focus)
    (return))
  (when (| (not (string== a b))
