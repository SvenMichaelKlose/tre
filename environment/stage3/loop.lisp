;;;;; tré – Copyright 2006,2008,2011–2014 (c) Sven Klose <pixel@copei.de>

(defmacro loop (&body body)
  (let tag (gensym)
    `(block nil
        (tagbody
          ,tag
          ,@body
          (go ,tag)))))
