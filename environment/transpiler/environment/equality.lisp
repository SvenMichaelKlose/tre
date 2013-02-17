;;;;; tré – Copyright (c) 2008–2009,2011–2013 Sven Michael Klose <pixel@copei.de>

(defun eql (x y)
  (| x (setq x nil))
  (| y (setq y nil))
  (| (%%%eq x y)
     (? (| (number? x) (number? y))
        (?
          (& (integer? x) (integer? y)) (integer== x y)
          (& (character? x) (character? y)) (character== x y))
        (== x y))))
