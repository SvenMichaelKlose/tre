;;;;; tré – Copyright (c) 2008,2011–2012 Sven Michael Klose <pixel@copei.de>

(defun tree-list-0 (q x)
  (? (atom x)
     (enqueue q x)
     (dolist (i x)
       (tree-list-0 q i))))

(defun tree-list (x)
  (& x
     (with-queue q
       (tree-list-0 q x)
       (queue-list q))))
