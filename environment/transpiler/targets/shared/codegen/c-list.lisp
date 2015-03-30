; tré – Copyright (c) 2008–2009,2011–2013,2015 Sven Michael Klose <pixel@copei.de>

(defun c-list (x &key (brackets :round))
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
