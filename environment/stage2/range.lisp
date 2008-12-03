;;;; TRE environment
;;;; Copyright (C) 2005-2006,2008 Sven Klose <pixel@copei.de>

(defun range-p (x bottom top)
  (and (>= x bottom)
	   (<= x top)))

; XXX tests missing
