;;;;; tré - Copyright (c) 2005-2006,2008,2012 Sven Michael Klose <pixel@copei.de>

(defmacro prog1 (&body body)
  (let g (gensym)
    `(let ,g ,(car body)
      ,@(cdr body)
      ,g)))
