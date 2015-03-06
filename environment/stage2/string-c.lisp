; tré – Copyright (c) 2005–2009,2011–2015 Sven Michael Klose <pixel@copei.de>

(defun upcase (str)
  (list-string (@ #'char-upcase (string-list str))))

(defun downcase (str)
  (list-string (@ #'char-downcase (string-list str))))

(define-test "UPCASE works"
  ((string== (upcase "lisp") "LISP"))
  t)

(define-test "DOWNCASE works"
  ((string== (downcase "LISP") "lisp"))
  t)
