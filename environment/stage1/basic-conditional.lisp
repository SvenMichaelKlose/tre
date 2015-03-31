; tré – Copyright (c) 2005,2008,2011–2014 Sven Michael Klose <pixel@copei.de>

(%defun compiler-& (x)
  (? .x
     `(? ,x.
         ,(compiler-& .x))
      x.))

(defmacro & (&rest x)
  (compiler-& x))

(%defun compiler-| (x)
  (? .x
     (let g (gensym)
       `(let ,g ,x.
          (? ,g
             ,g
             ,(compiler-| .x))))
     x.))

(defmacro | (&rest x)
  (compiler-| x))
