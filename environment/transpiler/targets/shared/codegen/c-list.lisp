(fn c-list (x &key (brackets :round))
  (with (err #'(() (error brackets "Expected :ROUND, :CURLY, :SQUARE or NIL in BRACKETS.")))
    `(,@(case brackets
          :round  '("(")
          :curly  '("{")
          :square '("[")
          :none   nil
          (err))
      ,@(pad x ", ")
      ,@(case brackets
          :round  '(")")
          :curly  '("}")
          :square '("]")
          :none   nil))))
