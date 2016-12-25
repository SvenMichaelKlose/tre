(defun precision-without-exponent (x prec)
  (alet (pow 10 prec) ; TODO: wrap POW in CL core.
	(/ (round (* x !)) !)))
