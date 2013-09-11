;;;;; tré – Copyright (c) 2008,2011–2013 Sven Michael Klose <pixel@copei.de>

(defun tree-list (&rest x)
  (with (rec [? (atom x)
                (enqueue q x)
                (adolist x
                  (rec q !))])
    (& x
       (with-queue q
         (rec q x)
         (queue-list q)))))
