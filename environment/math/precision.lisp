;;;;; Caroshi – Copyright (c) 2008–2009,2011–2013 Sven Michael Klose <pixel@copei.de>

(defun precision-without-exponent (x prec)
  (alet (pow 10 prec) ; XXX wrap POW in CL core.
	(/ (round (* x !)) !)))
