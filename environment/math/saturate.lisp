;;;;; tré – Copyright (c) 2008,2012 Sven Michael Klose <pixel@copei.de>

(defun saturates? (x y max)
  (> (+ x y) max))

(defun saturate (x y max)
  (if (saturates? x y max)
	  max
	  (+ x y)))

(defun desaturates? (x y &optional (min 0))
  (< (- x y) min))

(defun desaturate (x y &optional (min 0))
  (if (desaturates? x y min)
	  min
	  (- x y)))

(defmacro saturate! (place x max)
  `(setf ,place (saturate ,place ,x ,max)))

(defmacro desaturate! (place x &optional (min 0))
  `(setf ,place (desaturate ,place ,x ,min)))
