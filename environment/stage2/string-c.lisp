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
