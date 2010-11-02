;;;; TRE environment
;;;; Copyright (C) 2005-2009 Sven Klose <pixel@copei.de>

(defun %slot-value? (x)
  (and (consp x)
	   (eq '%SLOT-VALUE (car x))
	   (consp (cdr x))))

(defun slot-value? (x)
  (and (consp x)
	   (eq 'SLOT-VALUE (car x))
	   (consp (cdr x))))
