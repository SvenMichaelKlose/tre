;;;;; tré – Copyright (c) 2005–2008,2011–2013 Sven Michael Klose <pixel@copei.de>

(defmacro when (predicate &body body)
  `(& ,predicate
	  (progn ,@body)))

(defmacro unless (predicate &body body)
  `(when (not ,predicate)
     ,@body))

(defun group2 (x)
  (? x
     (cons (? (cdr x)
  		      (list (car x) (cadr x))
  		      (list (car x)))
           (group2 (cddr x)))))

(defmacro case (&body cases)
  (let g (gensym)
    (let op (? (eq :test (cadr cases))
               (? (atom (caddr cases))
                  (caddr cases)
                  (? (eq 'function (caaddr cases))
                     (cadaddr cases)
                     (error ":TEST must be a function.")))
               'equal)
        `(let ,g ,(car cases)
           (? 
             ,@(apply #'append (%simple-mapcar
						          #'((x)
              				          (? (cdr x)
                   				         `((,op ,g ,(car x)) ,(cadr x))
	   	          				         (list (car x))))
       				              (group2 (? (eq :test (cadr cases))
                                             (cdddr cases)
                                             (cdr cases))))))))))
