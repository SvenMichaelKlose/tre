;;;;; tré – Copyright (c) 2011–2012,2014 Sven Michael Klose <pixel@copei.de>

(defmacro cons-r (fun-name x &rest args)
  (let g (gensym)
    `(#'((,g)
          (. (,fun-name (car ,g) ,@args)
             (,fun-name (cdr ,g) ,@args)))
        ,x)))
