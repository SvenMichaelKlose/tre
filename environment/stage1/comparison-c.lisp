;;;;; tré – Copyright (c) 2005–2006,2008–2009,2012 Sven Michael Klose <pixel@copei.de>

(defun >= (n &rest x)
  (dolist (i x t)
    (| (== n i)
       (> n i)
       (return nil))
    (setq n i)))

(defun <= (n &rest x)
  (dolist (i x t)
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

(defun number>= (x y)
  (| (number== x y) (number> x y)))

(defun number<= (x y)
  (| (number== x y) (number< x y)))
