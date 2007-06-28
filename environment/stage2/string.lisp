;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005-2006 Sven Klose <pixel@copei.de>
;;;;
;;;; String functions

(defun string= (sa sb)
  "Return T if two strings match."
  (if (and (stringp sa) (stringp sb))
    (let ((la (length sa))
	  (lb (length sb)))
      (when (= la lb)
        (dotimes (i la t)
          (when (neql (elt sa i) (elt sb i))
            (return nil)))))
    (eql sa sb)))

(define-test "STRING= works"
  ((and (string= "abc" "abc")
        (not (string= "ABC" "abc"))
        (not (string= "abc" "abcd"))
        (not (string= "abcd" "abc"))))
  t)

(define-test "STRING= is safe"
  ((and (string= nil nil)
        (string= 1 1)
	(string= #'eq #'eq)))
  t)

(defun char-string (chr)
  (let ((s (make-string 1)))
    (setf (elt s 0) chr)
    s))

(define-test "CHAR-STRING works"
  ((string= (char-string #\A) "A"))
  t)

(defun list-string (lst)
  "Convert list of characters to string."
  (if lst
    (let* ((n (length lst))
           (s (make-string n)))
      (do ((i 0 (1+ i))
           (l lst (cdr l)))
          ((>= i n) s)
        (setf (elt s i) (car l))))))

(define-test "LIST-STRING works"
  ((string= (list-string '(#\L #\I #\S #\P))
	    "LISP"))
  t)

(defun string-upcase (str)
  "Return new string with characters converted to upper case."
  (when str
    (let* ((n (length str))
           (s (make-string n)))
      (do ((i 0 (1+ i)))
          ((= i n) s)
        (let ((c (elt str i)))
          (when (and (>= c #\a) (<= c #\z))
            (setf (elt s i) (char-upcase c))))))))

(define-test "STRING-UPCASE works"
  ((string= (string-upcase "lisp")
	    "LISP"))
  t)

(defun char-code (chr)
  (integer chr))
