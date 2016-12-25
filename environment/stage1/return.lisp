(defmacro return (&optional (expr nil))
  `(return-from nil ,expr))
