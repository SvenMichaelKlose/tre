;;;;; tré – Copyright (c) 2008,2011–2013 Sven Michael Klose <pixel@copei.de>

(defun tree-list-0 (q x)
  (? (atom x)
     (enqueue q x)
     (dolist (i x)
       (tree-list-0 q i))))

(defun tree-list (&rest x)
  (& x
     (with-queue q
       (tree-list-0 q x)
       (queue-list q))))
