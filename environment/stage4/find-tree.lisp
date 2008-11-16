;;;; TRE environment
;;;; Copyright (C) 2005-2008 Sven Klose <pixel@copei.de>

(defun find-tree (x v)
  (or (equal x v)
      (when (consp x)
        (or (find-tree (car x) v)   
            (find-tree (cdr x) v)))))
