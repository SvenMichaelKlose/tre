;;;; tré – Copyright (c) 2005–2008,2010–2012,2014 Sven Michael Klose <pixel@copei.de>

(defmacro do (binds (test &rest result) &body body)
  (let tag (gensym)
    `(block nil
       (let* ,(mapcar #'((b)
						  `(,b. ,.b.))
					 binds)
         (tagbody
           ,tag
           (? ,test
              (return (progn ,@result)))
           ,@body
           ,@(mapcar #'((b)
						  (& ..b.
						     `(setq ,b. ,..b.)))
					 binds)
           (go ,tag))))))
