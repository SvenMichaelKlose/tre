;;;; tré – Copyright (c) 2005–2009,2011–2012 Sven Michael Klose <pixel@copei.de>

(defun string-upcase (str)
  (when str
    (let* ((n (length str))
           (s (make-string 0)))
      (do ((i 0 (integer-1+ i)))
          ((integer== i n) s)
        (setf s (+ s (string (char-upcase (elt str i)))))))))

(define-test "STRING-UPCASE works"
  ((string== (string-upcase "lisp")
	    "LISP"))
  t)

(defun string-downcase (str)
  (when str
    (let* ((n (length str))
           (s (make-string 0)))
      (do ((i 0 (integer-1+ i)))
          ((integer== i n) s)
        (setf s (+ s (string (char-downcase (elt str i)))))))))

(define-test "STRING-DOWNCASE works"
  ((string== (string-downcase "LISP")
	    "lisp"))
  t)

(defun char-code (chr)
  (integer chr))
