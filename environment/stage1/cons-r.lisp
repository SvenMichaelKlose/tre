;;;;; tré - Copyright (c) 2011-2012 Sven Michael Klose <pixel@copei.de>

(defmacro cons-r (fun-name x &rest args)
  (let g (gensym)
    `(#'((,g)
          (cons (,fun-name (car ,g) ,@args)
                (,fun-name (cdr ,g) ,@args)))
        ,x)))
