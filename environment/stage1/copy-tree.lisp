(functional copy-tree)

(%defun copy-tree (x)
  (? (atom x)
     x
     (. (copy-tree x.)
        (copy-tree .x))))
