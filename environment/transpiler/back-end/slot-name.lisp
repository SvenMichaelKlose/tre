(fn compiled-slot-name (x)
  (pcase x
    %string? .x.
    symbol?  (convert-identifier (make-symbol (symbol-name x) "TRE"))
    x))
