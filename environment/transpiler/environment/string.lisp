(fn %=-elt-string (val seq idx)
  (error "Cannot modify strings."))

(fn string (x)
  (pcase x
    string?     x
    character?  (char-string x)
    symbol?     (symbol-name x)
    number?     (number-string x)
    not         "NIL"
    (error "Don't know how to convert ~A to string." x)))

(defmacro string== (x &rest y)
  (?
    .y
       `(& (%%%== ,x ,y.)
           (string== ,x ,.y))
     y.
       `(%%%== ,x ,y.)))
