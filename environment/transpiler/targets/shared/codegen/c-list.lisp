(fn c-list (x &key (parens-type :parens))
  (with (err #'(() (error "PARENS-TYPE ~A not :PARENS, :BRACES, :BRACKETS or NIL"
                          parens-type)))
    `(" "
      ,@(case parens-type
          :parens   '("(")
          :braces   '("{")
          :brackets '("[")
          nil       nil
          (err))
      ,@(pad x ", ")
      ,@(case parens-type
          :parens   '(")")
          :braces   '("}")
          :brackets '("]")
          nil))))
