;;;;; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate *math *p-i abs pow sqrt sin cos atan atan2)

(defconstant *pi* *math.*p-i)

(defun abs (x)     (*math.abs x))
(defun pow (x y)   (*math.pow x y))
(defun sqrt (x)    (*math.sqrt x))
(defun sin (x)     (*math.sin x))
(defun cos (x)     (*math.cos x))
(defun atan (x)    (*math.atan x))
(defun atan2 (a b) (*math.atan2 a b))
