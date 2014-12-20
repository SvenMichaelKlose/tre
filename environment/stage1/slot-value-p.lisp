;;;; tré – Copyright (c) 2005–2009,2011–2012,2014 Sven Michael Klose <pixel@copei.de>

(defun %slot-value? (x)
  (& (cons? x)
     (eq '%SLOT-VALUE x.)
     (cons? .x)))

(defun slot-value? (x)
  (& (cons? x)
     (eq 'SLOT-VALUE x.)
     (cons? .x)))
