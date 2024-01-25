(fn maphash (fun hash)
  (@ [~> fun _. ._]
     (object-alist hash)))  ; TODO: Handle HASH-TABLE. (pixel)
