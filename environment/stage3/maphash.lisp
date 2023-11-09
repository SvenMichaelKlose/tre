(fn maphash (fun hash)
  (@ [funcall fun _. ._]
     (object-alist hash)))
