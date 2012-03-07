;;;;; tré - Copyright (c) 2008-2010,2012 Sven Michael Klose <pixel@copei.de>

(defmacro define-tree-filter (name args &body body)
  (let iter (car (last args))
	(with-gensym fun
      `(defun ,name ,args
	     (with (,fun #'(,args
				          (if
					        ,@body
					        (atom ,iter)
					          ,iter
				            (cons (,fun ,@(butlast args) (car ,iter))
				     	          (,fun ,@(butlast args) (cdr ,iter))))))
	       (,fun ,@args))))))

(defmacro define-concat-tree-filter (name args &body body)
  (let iter (car (last args))
	(with-gensym fun
      `(defun ,name ,args
	     (with (,fun #'(,args
                          (mapcan #'((,iter)
                                      (if
					                    ,@body
					                    (atom ,iter)
					                      (list ,iter)
				                        (list (,fun ,@(butlast args) ,iter))))
                                  ,iter)))
	       (,fun ,@args))))))
