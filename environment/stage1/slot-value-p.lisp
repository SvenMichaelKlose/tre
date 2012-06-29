;;;; tré – Copyright (c) 2005–2009,2011–2012 Sven Michael Klose <pixel@copei.de>

(defun %slot-value? (x)
  (& (cons? x)
     (eq '%SLOT-VALUE (car x))
     (cons? (cdr x))))

(defun slot-value? (x)
  (& (cons? x)
     (eq 'SLOT-VALUE (car x))
     (cons? (cdr x))))
