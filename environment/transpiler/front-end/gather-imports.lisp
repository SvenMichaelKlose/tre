(define-tree-filter gather-imports-0 (x)
  (atom x) x
  (symbol? x.)
    (progn
      (add-wanted-function x.)
      (add-wanted-variable x.)
      (gather-imports-0 .x)))

(fn gather-imports (x)
  (gather-imports-0 x)
  x)
