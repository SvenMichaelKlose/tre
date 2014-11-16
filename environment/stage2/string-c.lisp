;;;; tré – Copyright (c) 2005–2009,2011–2014 Sven Michael Klose <pixel@copei.de>

(defun upcase (str)
  (list-string (filter [char-upcase _] (string-list str))))

(defun downcase (str)
  (list-string (filter [char-downcase _] (string-list str))))

(defun char-code (chr)
  (integer chr))

(define-test "UPCASE works"
  ((string== (upcase "lisp")
	    "LISP"))
  t)

(define-test "DOWNCASE works"
  ((string== (downcase "LISP")
	    "lisp"))
  t)
