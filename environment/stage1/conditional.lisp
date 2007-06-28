;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005-2006 Sven Klose <pixel@copei.de>
;;;;
;;;; Conditional evaluation

(defmacro when (test &rest expr)
  `(and
    ,test
    ; Encapsulate multiple expressions into PROGN.
    ,(if (cdr expr)
	`(progn ,@expr)
	(car expr))))

(defmacro unless (test &rest expr)
  `(when (not ,test) ,@expr))

(defmacro case (val &rest tests)
  (let ((g (gensym)))
    `(let ((,g ,val))
      (cond 
        ,@(%simple-mapcar
          #'(lambda ((test expr))
            (if (eq t test)
	      `(t ,expr)
              `((equal ,g ,test) ,expr)))
          tests)))))
