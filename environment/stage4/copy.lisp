(fn copy (x)
  (?
    (cons? x)       (copy-list x)
    (array? x)      (copy-array x)
    (hash-table? x) (copy-hash-table x)))
