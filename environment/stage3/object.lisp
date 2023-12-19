(fn json-object? (x) x nil)

(fn oref (o prop)
  (aref o props))

(fn (= oref) (v o prop)
  (= (aref o props) v))
