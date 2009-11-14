;;;; TRE environment
;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(defun empty-string? (x)
  "Tells if string is empty or contains just spaces."
  (when x
   	(aif (trim #\  x)
   	     (string= "" !)
		 t)))

; XXX Needs TRIM first.
(define-test "EMPTY-STRING? works"
  ((and (empty-string? "  ")
		(empty-string? "")))
  t)

(defun empty-string-or-nil? (x)
  (or (not x)
	  (empty-string? x)))
