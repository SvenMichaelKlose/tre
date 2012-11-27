;;;;; tré – Copyright (c) 2012 Sven Michael Klose <pixel@copei.de>

(defun copy (x)
  (?
    (cons? x)       (copy-list x)
    (array? x)      (copy-array x)
    (hash-table? x) (copy-hash-table x)))
