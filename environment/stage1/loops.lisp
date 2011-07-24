;;;; TRE environment
;;;; Copyright (c) 2005-2008,2010-2011 Sven Klose <pixel@copei.de>

(defmacro do (binds (test &rest result) &rest body)
  (let tag (gensym)
    `(block nil
       (let* ,(mapcar #'((b)
						  `(,(car b) ,(cadr b)))
					 binds)
         (tagbody
           ,tag
           (if ,test
               (return (progn
						 ,@result)))
           ,@body
           ,@(mapcar #'((b)
						  (and (caddr b)
							   `(setq ,(car b) ,(caddr b))))
					 binds)
           (go ,tag))))))

(defmacro dotimes ((iter times &rest result) &rest body)
  (let g (gensym)
    `(let ,g ,times
       (do ((,iter 0 (integer+ 1 ,iter)))
	       ((integer= ,iter ,times) ,@result)
	     ,@body))))

(defmacro dotimes-step ((iter times step &rest result) &rest body)
  `(do ((,iter 0 (integer+ ,step ,iter)))
	   ((not (integer< ,iter ,times)) ,@result)
	 ,@body))
