(def-head-predicate %%string) ; TODO: Move to transpiler/lib/metacode/. (pixel)

(define-tree-filter encapsulate-strings (x)
  (string? x)
    `(%%string ,x)
  (| (quote? x)
     (%%native? x)
     (%%comment? x))
    x)
