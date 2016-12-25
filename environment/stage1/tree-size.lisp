(defun tree-size (x &optional (n 0))
  (? (cons? x)
     (number+ 1 n (tree-size x.) (tree-size .x))
     n))
