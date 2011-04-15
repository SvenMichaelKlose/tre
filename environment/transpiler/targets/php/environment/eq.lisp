;;;;; Caroshi
;;;;; Copyright (c) 2011 Sven Klose <pixel@copei.de>

(defun eq (x y)
  (? (symbol? x)
     (and (symbol? y)
          (string= (symbol-name x) (symbol-name y))
          (%%%= (keyword? x) (keyword? y)))
     (%%%eq x y)))
