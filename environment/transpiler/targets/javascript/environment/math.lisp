;;;;; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate *math *p-i abs acos asin atan atan2 ceil cos exp floor log max min pow rount sin sqrt tan random)
(declare-cps-exception abs acos asin atan atan2 ceil cos exp floor log max min pow rount sin sqrt tan random)

(defconstant *pi* *math.*p-i)

(defun abs (x)     (*math.abs x))
(defun acos (x)    (*math.acos x))
(defun asin (x)    (*math.asin x))
(defun atan (x)    (*math.atan x))
(defun atan2 (a b) (*math.atan2 a b))
(defun ceil (x)    (*math.ceil x))
(defun cos (x)     (*math.cos x))
(defun exp (x)     (*math.exp x))
(defun floor (x)   (*math.floor x))
;(defun log (x)     (*math.log x))   ; TODO rename LOG in Caroshi.
;(defun max (a b)   (*math.max a b))
;(defun min (a b)   (*math.min a b))
(defun pow (x y)   (*math.pow x y))
(defun round (x)   (*math.round x))
(defun sin (x)     (*math.sin x))
(defun sqrt (x)    (*math.sqrt x))
(defun tan (x)     (*math.tan x))
(defun random ()   (*math.random))
