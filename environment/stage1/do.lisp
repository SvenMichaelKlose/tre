; tré – Copyright (c) 2005–2008,2010–2012,2014–2015 Sven Michael Klose <pixel@copei.de>

(defmacro do (binds (test &rest result) &body body)
  (let tag (gensym)
    `(block nil
       (let* ,(@ [`(,_. ,._.)] binds)
         (tagbody
           ,tag
           (? ,test
              (return (progn ,@result)))
           ,@body
           ,@(@ [& .._. `(setq ,_. ,.._.)] binds)
           (go ,tag))))))
