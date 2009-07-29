;;;;; TRE compiler
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defun list-aliases (x)
  (when x
    (cons (cons x. (gensym))
          (list-aliases .x))))
