;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005-2006 Sven Klose <pixel@copei.de>
;;;;
;;;; Local variables

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
(%defun %arg-keyword-p (arg)
  (cond
    ((eq arg '&rest) t)
    ((eq arg '&optional) t)
    ((eq arg '&key) t)))

;; Create new local variables.
;;
;; Inside the assignment list the local variables cannot be used.
;; Use LET* instead.
(defmacro let ((&rest alst) &rest body)
  (cond
    ((atom (car alst))
      (progn
        (print alst)
        (error "assignment list expected")))
    (t
      (progn
        ; Check on keyword arguments.
        (%simple-mapcar
          #'((expr)
              (cond
                ((%ltest #'%arg-keyword-p expr)
                  (error "illegal keyword argument"))))
          alst)

        ; Create LAMBDA expression.
        `(#'(,(%simple-mapcar #'car alst)
	            (progn ,@body))
          	  ,@(%simple-mapcar #'cadr alst))))))

;; Create new local variables.
;;
;; Multiple arguments are nested so init expressions can use formerly
;; defined variables inside the assignment list.
(defmacro let* (alst &rest body)
  ; Check if keyword arguments are used illegally.
  (cond
    ((%arg-keyword-p (car alst))
      (error "unexpected keyword"))
    ; Create nested LAMBDA expression.
    (t
      (cond
        ((not (cdr alst))
          `(#'((,(caar alst))
		(progn ,@body))
            ,@(cdar alst)))
        (t
          `(#'((,(caar alst))
		(let* ,(cdr alst)
		  (progn ,@body)))
	    ,@(cdar alst)))))))
