;;;; TRE environment
;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(defun empty-string? (x)
  "Tells if string is empty or contains just spaces."
  (when x
    (= "" (trim #\  x))))

; XXX Needs TRIM first.
;(define-test "EMPTY-STRING? works"
;  ((and (empty-string? "  ")
;		(empty-string? "")))
;  t)
