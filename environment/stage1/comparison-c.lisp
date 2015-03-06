; tré – Copyright (c) 2005–2006,2008–2009,2012–2015 Sven Michael Klose <pixel@copei.de>

(functional >= <= character>= character<= integer>= integer<= number>= number<=)

(defun >= (n &rest x)
  (@ (i x t)
    (| (== n i)
       (> n i)
       (return nil))
    (setq n i)))

(defun <= (n &rest x)
  (@ (i x t)
    (| (== n i)
       (< n i)
       (return nil))
    (setq n i)))

(defun character>= (x y)
  (| (character== x y) (character> x y)))

(defun character<= (x y)
  (| (character== x y) (character< x y)))

(defun integer>= (x y)
  (| (integer== x y) (integer> x y)))

(defun integer<= (x y)
  (| (integer== x y) (integer< x y)))
