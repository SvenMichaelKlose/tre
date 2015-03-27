; tré – Copyright (c) 2006,2009,2012–2015 Sven Michael Klose <pixel@copei.de>

(defmacro define-mapped-fun (mapfun name &rest fun)
  (with-gensym g
    `(defun ,name (,g)
       (,mapfun ,(? (& (not .fun)
                       (cons? fun.)
                       (eq 'function fun..))
                    fun.
                    `#'(,@fun))
                ,g))))

(defmacro define-filter (name &rest fun)
  `(define-mapped-fun filter ,name ,@fun))

(define-filter carlist #'car)
(define-filter cdrlist #'cdr)
(define-filter cadrlist #'cadr)
