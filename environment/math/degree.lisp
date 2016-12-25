(defun deg-rad (x) (/ (* x *pi*) 180))
(defun degree-sin (x) (sin (deg-rad x)))
(defun degree-cos (x) (cos (deg-rad x)))
