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

(defmacro dotimes ((iter times &rest result) &body body)
  (let g (gensym)
    `(let ,g (integer ,times)
       (do ((,iter 0 (integer+ 1 ,iter)))
	       ((integer== ,iter ,g) ,@result)
	     ,@body))))

(defmacro dotimes-step ((iter times step &rest result) &body body)
  `(do ((,iter 0 (integer+ ,step ,iter)))
	   ((not (integer< ,iter ,times)) ,@result)
	 ,@body))
