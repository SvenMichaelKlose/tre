;;;;; tré – Copyright (c) 2006,2009,2012–2013 Sven Michael Klose <pixel@copei.de>

(defmacro define-mapped-fun (mapfun name &rest fun)
  (with-gensym g
    `(defun ,name (,g)
       (,mapfun ,(? (& (not (cdr fun))
                       (cons? (car fun))
                       (eq 'function (caar fun)))
                    (car fun)
                    `#'(,@fun))
                ,g))))

(defmacro define-filter (name &rest fun)
  `(define-mapped-fun filter ,name ,@fun))

(defmacro define-mapcan-fun (name &rest fun)
  `(define-mapped-fun mapcan ,name ,@fun))

(define-filter carlist #'car)
(define-filter cdrlist #'cdr)
