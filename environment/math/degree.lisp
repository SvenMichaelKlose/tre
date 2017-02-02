(fn deg-rad (x)
  (/ (* x *pi*) 180))

(fn degree-sin (x)
  (sin (deg-rad x)))

(fn degree-cos (x)
  (cos (deg-rad x)))
