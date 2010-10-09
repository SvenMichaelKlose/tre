;;;; TRE environment
;;;; Copyright (c) 2005-2008 Sven Klose <pixel@copei.de>

(defmacro when (predicate &rest expr)
  `(and ,predicate
        ,(if (cdr expr)
	         `(progn ,@expr)
	         (car expr))))

(defmacro unless (predicate &rest expr)
  `(when (not ,predicate) ,@expr))

(defun group2 (x)
  (if x
      (cons (if (cdr x)
	  		    (list (car x) (cadr x))
	  		    (list (car x)))
	        (group2 (cddr x)))))

(defmacro case (val &rest cases)
  (let g (gensym)
    `(let ,g ,val
       (if 
         ,@(apply #'append (%simple-mapcar
						      #'((x)
              				      (if (cdr x)
                   				      `((equal ,g ,(car x)) ,(cadr x))
	   	          				      (list (car x))))
       				       (group2 cases)))))))
