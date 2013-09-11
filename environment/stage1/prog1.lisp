;;;;; tré – Copyright (c) 2005–2006,2008,2012–2013 Sven Michael Klose <pixel@copei.de>

(defmacro prog1 (&body body)
  (alet (gensym)
    `(let ,! ,(car body)
      ,@(cdr body)
      ,!)))
