(defmacro remove! (x lst &rest args)
  `(= ,lst (remove ,x ,lst ,@args)))
