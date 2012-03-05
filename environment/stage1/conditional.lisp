;;;;; tré - Copyright (c) 2005-2008,2011-2012 Sven Michael Klose <pixel@copei.de>

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

(defmacro case (&rest cases)
  (let g (gensym)
    (let op (if (eq :test (car cases))
                (if (atom (cadr cases))
                    (cadr cases)
                    (? (eq 'function (caadr cases))
                       (cadadr cases)
                       (%error "invalid predicate for TEST: FUNCTION expected")))
                'equal)
      (let v (if (eq :test (car cases))
                 (caddr cases)
                 (car cases))
        `(let ,g ,v
           (if 
             ,@(apply #'append (%simple-mapcar
						          #'((x)
              				          (if (cdr x)
                   				          `((,op ,g ,(car x)) ,(cadr x))
	   	          				          (list (car x))))
       				           (group2 (if (eq :test (car cases))
                                           (cdddr cases)
                                           (cdr cases)))))))))))
