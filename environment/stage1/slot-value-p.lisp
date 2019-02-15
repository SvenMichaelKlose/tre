(fn %slot-value? (x)
  (& (cons? x)
     (eq '%slot-value x.)
     (cons? .x)))

(fn slot-value? (x)
  (& (cons? x)
     (eq 'slot-value x.)
     (cons? .x)))

(fn prop-value? (x)
  (& (cons? x)
     (eq 'prop-value x.)
     (cons? .x)))
