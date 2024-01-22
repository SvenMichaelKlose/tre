(fn maphash (fun hash)
  (@ [funcall fun _. ._]
     (object-alist hash)))  ; TODO: Handle HASH-TABLE. (pixel)
