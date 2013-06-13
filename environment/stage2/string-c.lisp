;;;; tré – Copyright (c) 2005–2009,2011–2013 Sven Michael Klose <pixel@copei.de>

(defun string-upcase (str)
  (list-string (filter [char-upcase _] (string-list str))))

(define-test "STRING-UPCASE works"
  ((string== (string-upcase "lisp")
	    "LISP"))
  t)

(defun string-downcase (str)
  (list-string (filter [char-downcase _] (string-list str))))

(define-test "STRING-DOWNCASE works"
  ((string== (string-downcase "LISP")
	    "lisp"))
  t)

(defun char-code (chr)
  (integer chr))
