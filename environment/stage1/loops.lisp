;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005-2008 Sven Klose <pixel@copei.de>
;;;;
;;;; Loop macros

(defmacro do (binds (test &rest result) &rest body)
  (let tag (gensym)
    `(block nil
       (let* ,(mapcar #'((b)
						  `(,(first b) ,(second b)))
					 binds)
         (tagbody
           ,tag
           (if ,test
               (return (progn
						 ,@result)))
           ,@body
           ,@(mapcar #'((b)
						  (and (third b)
							   `(setq ,(first b) ,(third b))))
					 binds)
           (go ,tag))))))

(defmacro dotimes ((iter times &rest result) &rest body)
  `(do ((,iter 0 (+ 1 ,iter)))
	   ((not (< ,iter ,times)) ,@result)
	 ,@body))
