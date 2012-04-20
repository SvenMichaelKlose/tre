;;;;; tré - Copyright (c) 2006,2009,2012 Sven Michael Klose <pixel@copei.de>

(defmacro define-mapped-fun (mapfun name &rest fun)
  (with-gensym g
    `(defun ,name (,g)
       (,mapfun #'(,@fun) ,g))))

(defmacro define-filter (name &rest fun)
  `(define-mapped-fun filter ,name ,@fun))

(defmacro define-mapcan-fun (name &rest fun)
  `(define-mapped-fun mapcan ,name ,@fun))

(define-filter carlist (x)
  (car x))

(define-filter cdrlist (x)
  (cdr x))
