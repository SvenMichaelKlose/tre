(defmacro remove! (x lst &rest args)    ; TODO: Remove.
  `(= ,lst (remove ,x ,lst ,@args)))
