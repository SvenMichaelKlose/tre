;;;; TRE environment
;;;; Copyright (c) 2005-2006,2008,2011 Sven Klose <pixel@copei.de>

(functional range-p)

(defun range-p (x bottom top)
  (and (>= x bottom)
	   (<= x top)))

; XXX tests missing
