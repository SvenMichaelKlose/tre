;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005-2006,2008 Sven Klose <pixel@copei.de>
;;;;
;;;; Local variables

(%defun %chk-place (x)
  (cond
	((%arg-keyword? x)
		(print x)
	    (%error "place is an argument keyword"))))

(%defun %error-if-not-unique (x)
  (%simple-map #'((i)
					(cond
					  ((< 1 (count i x))
	  				     (print i)
	    				 (%error "place not unique"))))
			   x))

(%defun %let-places (x)
  (%simple-mapcar #'car x))

(%defun %let-chk-places (x)
  (cond
    ((atom x)
       (print x)
       (%error "assignment list expected instead of an atom")))
  (%simple-map #'%chk-place x)
  (%simple-map #'((p)
  					(cond
					  ((%error-if-not-unique (%let-places x))
						 (print x)
						 (%error "place is not unique"))))
			   x))

;; Create new local variables.
;;
;; Multiple arguments are nested so init expressions can use formerly
;; defined variables inside the assignment list.
(defmacro let* (alst &rest body)
  (cond
    ((not alst)
	   `(progn
		  ,@body))

    ((not (cdr alst))
       (%let-chk-places alst)
       `(let ,(caar alst) ,(cadar alst)
		   ,@body))

    (t (%let-chk-places alst)
	   `(let ,(caar alst) ,(cadar alst)
		  (let* ,(cdr alst)
			,@body)))))
