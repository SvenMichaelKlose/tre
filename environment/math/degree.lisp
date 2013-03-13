;;;;; tré – Copyright (c) 2008–2009,2011–2013 Sven Michael Klose <pixel@copei.de>

(defun rad-deg (x) (* x *pi* 180))
(defun degree-sin (x) (sin (rad-deg x)))
(defun degree-cos (x) (cos (rad-deg x)))
