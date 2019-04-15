(%fn compiler-& (x)
  (? .x
     `(? ,x.
         ,(compiler-& .x))
      x.))

(defmacro & (&rest x)
  (compiler-& x))

(%fn compiler-| (x)
  (? .x
     (#'((g)
           `(#'((,g)
                  (? ,g
                     ,g
                     ,(compiler-| .x)))
                ,x.))
         (gensym))
     x.))

(defmacro | (&rest x)
  (compiler-| x))
