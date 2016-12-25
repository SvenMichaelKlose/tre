(defun tree-list-0 (q x)
  (? (atom x)
     (enqueue q x)
     (@ (i x)
       (tree-list-0 q i))))

(defun tree-list (&rest x)
  (& x
     (with-queue q
       (tree-list-0 q x)
       (queue-list q))))
