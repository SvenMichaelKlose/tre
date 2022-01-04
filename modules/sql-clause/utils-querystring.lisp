(macrolet ((defsqlutil (name op)
            `(fn ,name (x y)
               (+ " "
                  (? (symbol? x)
                     (downcase (symbol-name x))
                     x)
                  ,op
                  "\"" (escape-string (string y)) "\""))))
  (defsqlutil sql= "=")
  (defsqlutil sql!= "!=")
  (defsqlutil sql< "<")
  (defsqlutil sql> ">"))

(fn sql-like (field val)
  `(,field " LIKE \"%" ,(escape-string val) "%\" "))

(fn sql-integer (x)
  (string (integer x)))
