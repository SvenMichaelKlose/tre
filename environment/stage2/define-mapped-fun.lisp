;;;;; TRE environment
;;;;; Copyright (C) 2006,2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Mapping utilities

(defmacro define-mapped-fun (mapfun name &rest fun)
  (with-gensym g
    `(defun ,name (,g)
       (,mapfun #'(,@fun) ,g))))

(defmacro define-mapcar-fun (name &rest fun)
  `(define-mapped-fun mapcar ,name ,@fun))

(define-mapcar-fun carlist (a)
  (car a))

(defun cdrlist (x)
  (when x
    (cons (cdr (car x))
		  (cdrlist (cdr x)))))
