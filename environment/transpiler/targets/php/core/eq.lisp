;;;;; tré – Copyright (c) 2011–2012 Sven Michael Klose <pixel@copei.de>

(defun eq (x y)
  (| (& (is_a x "__cons") (is_a y "__cons")
        (%%%== x.id y.id))
     (& (is_a x "__symbol") (is_a y "__symbol")
        (%%%== x.n y.n)
        (%%%== (keyword? x) (keyword? y)))
     (%%%eq x y)))
