(defun %slot-value? (x)
  (& (cons? x)
     (eq '%SLOT-VALUE x.)
     (cons? .x)))

(defun slot-value? (x)
  (& (cons? x)
     (eq 'SLOT-VALUE x.)
     (cons? .x)))
