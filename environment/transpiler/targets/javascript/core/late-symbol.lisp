(fn make-symbol (x &optional (pkg nil))
  (symbol x pkg))

(fn make-package (x)
  (symbol x nil))

(fn symbol-name (x)
  (?
    (%%%eq t x)     "T"
    (%%%eq false x) "FALSE"
    x               x.n
    "NIL"))

(fn symbol-value (x)
  (?
    (%%%eq t x)  t
    x            x.v))

(fn symbol-function (x)
  (?
    (%%%eq t x)  nil
    x            x.f))

(fn symbol-package (x)
  (?
    (%%%eq t x)  nil
    x            (!? x.p ! 'tre)))

(fn symbol? (x)
  (| (not x)
     (%%%eq t x)
     (& (object? x)
         x.__class
         (%%%== x.__class ,(convert-identifier 'symbol)))))

(fn package-name (x)
  x.n)
