;;;;; tré – Copyright (c) 2005–2008,2010–2012 Sven Michael Klose <pixel@copei.de>

(defmacro do (binds (test &rest result) &body body)
  (let tag (gensym)
    `(block nil
       (let* ,(mapcar #'((b)
						  `(,(car b) ,(cadr b)))
					 binds)
         (tagbody
           ,tag
           (? ,test
              (return (progn ,@result)))
           ,@body
           ,@(mapcar #'((b)
						  (& (caddr b)
						     `(setq ,(car b) ,(caddr b))))
					 binds)
           (go ,tag))))))
