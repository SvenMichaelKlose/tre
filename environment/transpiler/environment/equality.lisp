; tré – Copyright (c) 2008–2009,2011–2014,2016 Sven Michael Klose <pixel@copei.de>

(declare-cps-exception %eql eql)

(defun eql (x y)
  (| x (setq x nil))
  (| y (setq y nil))
  (| (eq x y)
     (?
       (& (integer? x)
          (integer? y))     (integer== x y)
       (& (character? x)
          (character? y))   (character== x y)
       (& (number? x)
          (number? y))      (== x y)
       (& (string? x)
          (string? y))      (string== x y))))
