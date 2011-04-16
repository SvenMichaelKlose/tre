;;;;; Caroshi
;;;;; Copyright (c) 2011 Sven Klose <pixel@copei.de>

(dont-obfuscate is_a)

(defun eq (x y)
  (or (%%%eq x y)
      (and (is_a x "__symbol") (is_a y "__symbol")
           (%%%= x.n y.n)
           (%%%= (keyword? x) (keyword? y)))))
