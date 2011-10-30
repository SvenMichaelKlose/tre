;;;;; tré - Copyright (c) 2005-2006,2008-2009 Sven Klose <pixel@copei.de>

(defun >= (x y)
  (or (= x y)
      (> x y)))

(defun <= (x y)
  (or (= x y)
      (< x y)))

(defun character>= (x y)
  (or (character= x y)
      (character> x y)))

(defun character<= (x y)
  (or (character= x y)
      (character< x y)))

(defun integer>= (x y)
  (or (integer= x y)
      (integer> x y)))

(defun integer<= (x y)
  (or (integer= x y)
      (integer< x y)))

(defun number>= (x y)
  (or (number= x y)
      (number> x y)))

(defun number<= (x y)
  (or (number= x y)
      (number< x y)))
