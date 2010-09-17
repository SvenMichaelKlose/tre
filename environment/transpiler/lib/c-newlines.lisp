;;;;; TRE transpiler
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defun make-c-newlines (x)
  (list-string (mapcan (fn (if (= 10 _)
                               (list #\\ #\n)
                               (list _)))
                       (string-list x))))
