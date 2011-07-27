;;;;; TRE - Copyright (c) 2011 Sven Klose <pixel@copei.de>

(defmacro cons-r (fun-name x)
  (let g (gensym)
    `(#'((,g)
          (cons (,fun-name (car ,g))
                (,fun-name (cdr ,g))))
        ,x)))
