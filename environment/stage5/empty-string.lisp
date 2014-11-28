;;;;; tré – Copyright (c) 2008–2009.2011–2014 Sven Michael Klose <pixel@copei.de>

(defun empty-string? (&rest x)
  (every [& (string? _)
            (string== "" (| (trim _ " " :test #'string==) ""))] x))

(define-test "EMPTY-STRING? works"
  ((empty-string? "  " ""))
  t)
