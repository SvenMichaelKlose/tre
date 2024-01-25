(fn @ (x &rest keys)
  (!= (?
        (list? x)        (cdr (assoc keys. x))
        (array? x)       (aref x keys.)
        (hash-table? x)  (href x keys.)
        (error "Can only handle alists, ARRAY or HASH-TABLE, but got ~A.~%" x))
    (? .keys
       (~> #'@ ! .keys)
       !)))
