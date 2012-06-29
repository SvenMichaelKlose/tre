;;;;; tré – Copyright (c) 2008–2009.2011–2012 Sven Michael Klose <pixel@copei.de>

(defun %empty-string? (x)
  (string== "" (| (trim #\  x) "")))

(defun empty-string? (&rest x)
  (& x (every #'%empty-string? x)))

(define-test "EMPTY-STRING? works"
  ((empty-string? "  " ""))
  t)

(defun %empty-string-or-nil? (x)
  (| (not x)
     (%empty-string? x)))

(defun empty-string-or-nil? (&rest x)
  (& x (every #'%empty-string-or-nil? x)))
