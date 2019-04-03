(fn precision-without-exponent (x prec)
  (!= (pow 10 prec)
    (/ (round (* x !)) !)))
