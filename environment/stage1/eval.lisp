;;;;; tré - Copyright (c) 2005-2006,2008 Sven Klose <pixel@copei.de>

(defmacro return (&optional (expr nil))
  `(return-from nil ,expr))

(defmacro prog1 (&rest body)
  (let g (gensym)
    `(let ,g ,(car body)
      ,@(cdr body)
      ,g)))
