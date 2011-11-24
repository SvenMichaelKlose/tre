;;;;; tré - Copyright (c) 2009,2011 Sven Klose <pixel@copei.de>

(defun list-aliases (x &key (gensym-generator #'gensym))
  (when x
    (cons (cons x. (funcall gensym-generator))
          (list-aliases .x))))
