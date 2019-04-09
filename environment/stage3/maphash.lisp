(fn maphash (fun hash)
  (@ (i (%properties-list hash))
    (funcall fun i. .i)))
