;;;; TRE environment
;;;; Copyright (c) 2005-2009 Sven Klose <pixel@copei.de>
;;;;
;;;; String functions

(defun string= (sa sb)
  "Return T if two strings match."
  (if (and (stringp sa)
		   (stringp sb))
    (let* ((la (length sa))
	       (lb (length sb)))
      (when (= la lb)
        (dotimes (i la t)
          (unless (eql (elt sa i) (elt sb i))
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

;(defun list-string (lst)
;  "Convert list of characters to string."
;  (let* ((n (length lst))
;         (s (make-string 0)))
;    (do ((i 0 (1+ i))
;         (l lst (cdr l)))
;        ((>= i n) s)
;      (setf s (+ s (string (car l)))))))

(define-test "LIST-STRING works"
  ((string= (list-string '(#\L #\I #\S #\P))
	    "LISP"))
  t)

(defun string-list (x)
  "Make list of characters from string."
  (let* ((l (length x))
		 (s))
    (do ((i (1- l) (1- i)))
		((< i 0))
      (setf s (push (elt x i) s)))
	s))

(define-test "STRING-LIST works"
  ((equal (string-list "LISP") '(#\L #\I #\S #\P)))
  t)

(defun queue-string (x)
  "Convert queue of characters to string."
  (list-string (queue-list x)))

(defun string-upcase (str)
  "Return new string with characters converted to upper case."
  (when str
    (let* ((n (length str))
           (s (make-string 0)))
      (do ((i 0 (1+ i)))
          ((= i n) s)
        (setf s (+ s (string (char-upcase (elt str i)))))))))

(define-test "STRING-UPCASE works"
  ((string= (string-upcase "lisp")
	    "LISP"))
  t)

(defun string-downcase (str)
  "Return new string with characters converted to lower case."
  (when str
    (let* ((n (length str))
           (s (make-string 0)))
      (do ((i 0 (1+ i)))
          ((= i n) s)
        (setf s (+ s (string (char-downcase (elt str i)))))))))

(define-test "STRING-DOWNCASE works"
  ((string= (string-downcase "LISP")
	    "lisp"))
  t)

(defun char-code (chr)
  (integer chr))
