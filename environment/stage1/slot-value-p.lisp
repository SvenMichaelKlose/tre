(fn %slot-value? (x)
  (& (cons? x)
     (eq '%slot-value x.)
     (cons? .x)))

(fn slot-value? (x)
  (& (cons? x)
     (eq 'slot-value x.)
     (cons? .x)))
