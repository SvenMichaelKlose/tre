(fn maphash (fun hash)
  (@ (i (object-alist hash))
    (funcall fun i. .i)))
