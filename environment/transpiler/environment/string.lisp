(fn string (x)
  (pcase x
    string?     x
    character?  (char-string x)
    symbol?     (symbol-name x)
    number?     (number-string x)
    function?   "[FUNCTION]"
    not         "NIL"
    (error "Don't know how to convert A to string.")))
