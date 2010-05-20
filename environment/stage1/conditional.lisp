;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005-2008 Sven Klose <pixel@copei.de>
;;;;
;;;; Conditional evaluation

(defmacro when (predicate &rest expr)
  `(and ,predicate
        ; Encapsulate multiple expressions into PROGN.
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
