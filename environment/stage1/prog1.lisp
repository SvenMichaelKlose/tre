;;;; tré – Copyright (c) 2005–2006,2008,2012–2014 Sven Michael Klose <pixel@copei.de>

(defmacro prog1 (&body body)
  (alet (gensym)
    `(let ,! ,body.
      ,@.body
      ,!)))
