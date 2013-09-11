;;;;; tré – Copyright 2006,2008,2011–2013 (c) Sven Klose <pixel@copei.de>

(defmacro loop (&rest body)
  (let tag (gensym)
    `(block nil
        (tagbody
          ,tag
          ,@body
          (go ,tag)))))
