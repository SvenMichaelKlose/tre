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
