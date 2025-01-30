(def-compiler-macro progn (&body body)
  (!? body
      `(%block
         ,@(wrap-atoms !))))
