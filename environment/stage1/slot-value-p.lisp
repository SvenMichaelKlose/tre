(fn %slot-value? (x)
  (& (cons? x)
     (eq '%SLOT-VALUE x.)
     (cons? .x)))

(fn slot-value? (x)
  (& (cons? x)
     (eq 'SLOT-VALUE x.)
     (cons? .x)))
