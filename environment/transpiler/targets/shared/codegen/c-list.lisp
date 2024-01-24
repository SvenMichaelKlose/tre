(fn c-list (x &key (parens-type :parens))
  (with (err #'(() (error "Expected :PARENS, :BRACES, :BRACKETS or NIL in PARENS-TYPE instead of ~A." parens-type)))
    `(" "
      ,@(case parens-type
          :parens    '("(")
          :braces    '("{")
          :brackets  '("[")
          nil        nil
          (err))
      ,@(pad x ", ")
      ,@(case parens-type
          :parens    '(")")
          :braces    '("}")
          :brackets  '("]")
          nil))))
