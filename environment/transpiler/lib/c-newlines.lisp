;;;;; tré – Copyright (c) 2009,2012 Sven Michael Klose <pixel@copei.de>

(defun make-c-newlines (x)
  (list-string (mapcan (fn ? (== 10 _)
                             `(#\\ #\n)
                             `(,_))
                       (string-list x))))
