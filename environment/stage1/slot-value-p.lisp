;;;; TRE environment
;;;; Copyright (C) 2005-2009,2011 Sven Klose <pixel@copei.de>

(defun %slot-value? (x)
  (and (cons? x)
	   (eq '%SLOT-VALUE (car x))
	   (cons? (cdr x))))

(defun slot-value? (x)
  (and (cons? x)
	   (eq 'SLOT-VALUE (car x))
	   (cons? (cdr x))))
