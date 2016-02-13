; tré – Copyright (c) 2005–2006,2008–2009,2012–2016 Sven Michael Klose <pixel@hugbox.org>

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

(defun character>= (&rest x)
  (apply #'>= (@ #'char-code x)))

(defun character<= (&rest x)
  (apply #'<= (@ #'char-code x)))

(defun integer>= (x y)
  (| (integer== x y) (integer> x y)))

(defun integer<= (x y)
  (| (integer== x y) (integer< x y)))
