;;;; tré - Copyright (c) 2005-2006,2008,2012 Sven Michael Klose <pixel@copei.de>

(%defun %chk-place (x)
  (? (%arg-keyword? x)
     (progn
	   (print x)
	   (%error "place is an argument keyword"))))

(%defun %error-if-not-unique (x)
  (%simple-map #'((i)
					(? (< 1 (count i x))
					   (progn
	  				     (print i)
	    			     (%error "place not unique"))))
			   x))

(%defun %let-places (x)
  (%simple-mapcar #'car x))

(%defun %let-chk-places (x)
  (? (atom x)
     (progn
       (print x)
       (%error "assignment list expected instead of an atom")))
  (%simple-map #'%chk-place x)
  (%simple-map #'((p) (%error-if-not-unique (%let-places x)))
			   x))

(defmacro let* (alst &body body)
  (?
    (not alst)
	  `(progn
		 ,@body)

    (not (cdr alst))
	  (progn
         (%let-chk-places alst)
         `(let ,(caar alst) ,(cadar alst)
		    ,@body))

    (progn
	  (%let-chk-places alst)
	  `(let ,(caar alst) ,(cadar alst)
		 (let* ,(cdr alst)
		   ,@body)))))
