(defmacro in-package (x)
  (cl:in-package (symbol-name x)))
