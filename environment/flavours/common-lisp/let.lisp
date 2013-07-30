;;;;; tré – Copyright (C) 2005–2006,2008,2013 Sven Michael Klose <pixel@copei.de>

(%defun %ltest (test lst)
  (cond
    (lst
      (cond
        ((apply test (list (car lst))) t)
         (t (%ltest test (cdr lst)))))))

;;; Function definition.
;;;
;;; This functions check if the arguments and keywords are in place.

;; Check if atom is an argument keyword.
(%defun %arg-keyword? (x)
  (cond
    ((eq x '&rest) t)
    ((eq x '&optional) t)
    ((eq x '&key) t)))

(%defun %chk-place (x)
  (cond
	((%arg-keyword? x)
		(print x)
	    (%error "Place is an argument keyword."))))

(%defun %error-if-not-unique (x)
  (%simple-map #'((i)
					(cond
					  ((< 1 (count i x))
	  				     (print i)
	    				 (%error "Place not unique."))))
			   x))

(%defun %let-places (x)
  (%simple-mapcar #'car x))

(%defun %let-chk-places (x)
  (cond
    ((atom x)
       (print x)
       (%error "Assignment list expected instead of an atom.")))
  (%simple-map #'%chk-place x)
  (%simple-map #'((p)
  					(cond
					  ((%error-if-not-unique (%let-places x))
						 (print x)
						 (%error "Place is not unique."))))
			   x))

;; Create new local variables.
;;
;; Inside the assignment list the local variables cannot be used.
;; Use LET* instead.
(defmacro let (alst &rest body)
  (cond
	((not alst)
	   `(progn
		  ,@body))

    (t
	   (%let-chk-places alst)

       ; Create LAMBDA expression.
	   `(#'(,(%simple-mapcar #'car alst)
			  ,@body) ,@(%simple-mapcar #'cadr alst)))))

;; Create new local variables.
;;
;; Multiple arguments are nested so init expressions can use formerly
;; defined variables inside the assignment list.
(defmacro let* (alst &rest body)
  (%let-chk-places alst)
  (cond
    ((not alst)
	   `(progn
		  ,@body))

    ((not (cdr alst))
       `(let ((,(caar alst) ,(cadar alst)))
		   ,@body))

    (t `(let ((,(caar alst) ,(cadar alst)))
		  (let* ,(cdr alst)
			,@body)))))
