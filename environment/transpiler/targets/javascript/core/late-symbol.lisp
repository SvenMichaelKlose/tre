(fn make-symbol (x &optional (pkg nil))
  (symbol x pkg))

(fn make-package (x)
  (symbol x nil))

(fn symbol-name (x)
  (?
    (%%%=== t x)     "T"
    (%%%=== false x) "FALSE"
    x               x.n
    "NIL"))

(fn symbol-value (x)
  (?
    (%%%=== t x)  t
    x            x.v))

(fn symbol-function (x)
  (?
    (%%%=== t x)  nil
    x            x.f))

(fn symbol-package (x)
  (?
    (%%%=== t x)  nil
    x            (!? x.p ! 'tre)))

(fn symbol? (x)
  (| (not x)
     (%%%=== t x)
     (& (object? x)
         x.__class
         (%%%=== x.__class ,(convert-identifier 'symbol)))))

(fn package-name (x)
  x.n)

(fn find-symbol (name pkg))
