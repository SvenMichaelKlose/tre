(fn precision-without-exponent (x prec)
  (alet (pow 10 prec)
	(/ (round (* x !)) !)))
