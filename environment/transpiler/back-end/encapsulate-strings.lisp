(def-head-predicate %%string)

(define-tree-filter encapsulate-strings (x)
  (string? x)         `(%%string ,x)
  (| (quote? x)
     (%%native? x)
     (%%comment? x))  x)
