(defun tree-size (x &optional (n 0))
  (? (cons? x)
     (integer+ 1 n (tree-size x.) (tree-size .x))
     n))
