;;;; TRE environment
;;;; Copyright (C) 2005-2009 Sven Klose <pixel@copei.de>

(defun find-tree (x v)
  (or (equal x v)
      (when (consp x)
        (or (find-tree x. v)   
            (find-tree .x v)))))
