(fn deg-rad (x)
  (/ (* x *pi*) 180))

(fn rad-deg (x)
  (/ (* x 180) *pi*))

(fn degree-sin (x)
  (sin (deg-rad x)))

(fn degree-cos (x)
  (cos (deg-rad x)))
