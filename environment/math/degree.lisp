;;;;; tré – Copyright (c) 2008–2009,2011–2013 Sven Michael Klose <pixel@copei.de>

(defun deg-rad (x) (/ (* x *pi*) 180))
(defun degree-sin (x) (sin (deg-rad x)))
(defun degree-cos (x) (cos (deg-rad x)))
