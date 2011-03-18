;;;; TRE environment
;;;; Copyright (c) 2008-2009.2011 Sven Klose <pixel@copei.de>

(defun %empty-string? (x)
  (string= "" (or (trim #\  x) "")))

(defun empty-string? (&rest x)
  (when x
   	(every #'%empty-string? x)))

(define-test "EMPTY-STRING? works"
  ((empty-string? "  " ""))
  t)

(defun %empty-string-or-nil? (x)
  (or (not x)
      (%empty-string? x)))

(defun empty-string-or-nil? (&rest x)
  (when x
    (every #'%empty-string-or-nil?  x)))
