(= (symbol-function 'cons) "tre_cons")

(fn car (x)
  (& x x.a))

(fn cdr (x)
  (& x x.d))

(fn rplaca (x val)
  (= x.a val)
  x)

(fn rplacd (x val)
  (= x.d val)
  x)

(fn cons? (x)
  (is_a x "__cons"))
