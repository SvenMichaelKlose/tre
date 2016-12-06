; tré – Copyright (c) 2005–2008,2011–2014,2016 Sven Michael Klose <pixel@copei.de>

(defmacro when (predicate &body body)
  `(& ,predicate
	  {,@body}))

(defmacro unless (predicate &body body)
  `(when (not ,predicate)
     ,@body))

(defun group2 (x)
  (? x
     (. (? .x
  		   (list x. .x.)
  		   (list x.))
        (group2 ..x))))

(defun %case-test (cases)
  (? (eq :test .cases.)
     (? (atom ..cases.)
        ..cases.
        (? (eq 'function (caar ..cases))
           (cadar ..cases)
           (error ":TEST must be a function.")))
        'equal))
 
(defun %case (g cases)
  (let test (%case-test cases)
    (%simple-mapcar #'((x)
                         (? .x
                            `((,test ,g ,x.) ,.x.)
                            (list x.)))
                    (group2 (? (eq :test .cases.)
                               ...cases
                               .cases)))))

(defmacro case (&body cases)
  (& (keyword? cases.)
     (error "CASE value is a keyword."))
  (let g (gensym)
    `(let ,g ,cases.
       (? 
         ,@(apply #'append (%case g cases))))))
