;;;;; TRE environment - editor
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Some math.

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

(defmacro saturate! (place x y max)
  `(setf ,place (saturate ,x ,y ,max)))

(defmacro desaturate! (place x y &optional (min 0))
  `(setf ,place (desaturate ,x ,y ,min)))
