;;;;; tré – Copyright (c) 2005–2008,2011–2013 Sven Michael Klose <pixel@copei.de>

(defmacro when (predicate &body body)
  `(& ,predicate
	  (progn ,@body)))

(defmacro unless (predicate &body body)
  `(when (not ,predicate) ,@body))

(defun group2 (x)
  (? x
     (cons (? (cdr x)
  		      (list (car x) (cadr x))
  		      (list (car x)))
           (group2 (cddr x)))))

(defmacro case (&body cases)
  (let g (gensym)
    (let op (? (eq :test (car cases))
               (? (atom (cadr cases))
                  (cadr cases)
                  (? (eq 'function (caadr cases))
                     (cadadr cases)
                     (%error ":TEST expects a FUNCTION.")))
               'equal)
      (let v (? (eq :test (car cases))
                (caddr cases)
                (car cases))
        `(let ,g ,v
           (? 
             ,@(apply #'append (%simple-mapcar
						          #'((x)
              				          (? (cdr x)
                   				         `((,op ,g ,(car x)) ,(cadr x))
	   	          				         (list (car x))))
       				           (group2 (? (eq :test (car cases))
                                          (cdddr cases)
                                          (cdr cases)))))))))))
