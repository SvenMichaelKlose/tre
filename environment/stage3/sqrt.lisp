;;;;; TRE environment
;;;;; Copyright (C) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Square root
;;;;;
;;;;; XXX experimental

(defun close-enough? (x y precision)
  (> precision (abs (- x y))))

(defun fixed-point (f start precision)
  (with (iter #'((old new)
				   (if (close-enough? old new precision)
					   new
					   (iter new (f new)))))
	(iter start (f start))))

(defun average (a b)
  (/ (+ a b) 2))

(defun average-damp (f)
  #'((x)
       (average (f x) x)))

(defun derivative (f precision)
  #'((x)
	   (/ (- (f (+ x precision))
			 (f x))
		  precision)))

(defvar *newton-precision* 0.00001)

(defun newton (f &optional (guess 1) (precision *newton-precision*))
  "Finds root of a function"
  (with (df (derivative f precision))
	(fixed-point #'((x)
					  (- x (/ (f x) (df x))))
				 guess)))

(defun sqrt (x)
  (newton #'((y)
			   (- x (square y)))))
