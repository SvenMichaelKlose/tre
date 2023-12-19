(functional copy)
(fn copy (x)
  (?
    (cons? x)         (copy-list x)
    (array? x)        (copy-array x)
    (json-object? x)  (copy-props x)
    (hash-table? x)   (copy-hash-table x))
    (error (+ "COPY can only handle lists, arrays, JSON objects"
              " and hash tables.")))
