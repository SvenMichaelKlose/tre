;;;;; tré – Copyright (c) 2008–2009.2011–2013 Sven Michael Klose <pixel@copei.de>

(defun empty-string? (&rest x)
  (every [string== "" (| (trim #\  _) "")] x))

(defun empty-string-or-nil? (&rest x)
  (every [| (not _)
            (empty-string? _)]
         x))

(define-test "EMPTY-STRING? works"
  ((empty-string? "  " ""))
  t)
