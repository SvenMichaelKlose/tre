;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005-2006,2008 Sven Klose <pixel@copei.de>
;;;;
;;;; Local variables

(%defun %chk-place (x)
  (if (%arg-keyword? x)
	  (progn
		(print x)
	    (%error "place is an argument keyword"))))

(%defun %error-if-not-unique (x)
  (%simple-map #'((i)
					(if (< 1 (count i x))
						(progn
	  				      (print i)
	    				  (%error "place not unique"))))
			   x))

(%defun %let-places (x)
  (%simple-mapcar #'car x))

(%defun %let-chk-places (x)
  (if (atom x)
	  (progn
        (print x)
        (%error "assignment list expected instead of an atom")))
  (%simple-map #'%chk-place x)
  (%simple-map #'((p) (%error-if-not-unique (%let-places x)))
			   x))

;; Create new local variables.
;;
;; Multiple arguments are nested so init expressions can use formerly
;; defined variables inside the assignment list.
(defmacro let* (alst &rest body)
  (if
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
