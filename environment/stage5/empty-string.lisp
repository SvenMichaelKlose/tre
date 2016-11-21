; tré – Copyright (c) 2008–2009.2011–2014,2016 Sven Michael Klose <pixel@copei.de>

(defun empty-string? (&rest x)
  (every [& (string? _)
            (string== "" (| (trim _ " " :test #'string==) ""))] x))

(defun empty-string-or-nil? (x)
  (| (not x)
     (& (string? x)
        (string== "" x))))

(define-test "EMPTY-STRING? works"
  ((empty-string? "  " ""))
  t)
