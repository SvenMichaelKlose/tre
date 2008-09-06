;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005-2008 Sven Klose <pixel@copei.de>
;;;;
;;;; Conditional evaluation

(defmacro when (predicate &rest expr)
  `(and
    ,predicate
    ; Encapsulate multiple expressions into PROGN.
    ,(if (cdr expr)
	`(progn ,@expr)
	(car expr))))

(defmacro unless (predicate &rest expr)
  `(when (not ,predicate) ,@expr))

(defmacro case (val &rest cases)
  (let ((g (gensym)))
    `(let ((,g ,val))
      (cond 
        ,@(%simple-mapcar
            #'((x)
                  (if (eq t (car x))
	      	          `(t ,@(cdr x))
                      `((equal ,g ,(car x)) ,@(cdr x))))
            cases)))))
