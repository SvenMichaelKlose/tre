;;;; TRE environment
;;;; Copyright (c) 2008-2009.2011 Sven Klose <pixel@copei.de>

(defun %empty-string? (x)
  (string= "" (or (trim #\  x) "")))

(defun empty-string-0? (x)
  (? x
     (and (%empty-string? x.)
          (empty-string-0? .x))
	 t))

(defun empty-string? (&rest x)
  (when x
   	(empty-string-0? x)))

; XXX Needs TRIM first.
(define-test "EMPTY-STRING? works"
  ((and (empty-string? "  ")
		(empty-string? "")))
  t)

(defun empty-string-or-nil? (&rest x)
  (every (fn or (not _)
                (%empty-string? _))
         x))
