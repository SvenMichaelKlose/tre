(defmacro define-filter (name &rest fun)
  (with-gensym g
    `(fn ,name (,g)
       (filter ,(? (& (not .fun)
                      (function-expr? fun.))
                   fun.
                   `#'(,@fun))
               ,g))))

(define-filter carlist #'car)
(define-filter cdrlist #'cdr)
(define-filter cadrlist #'cadr)
