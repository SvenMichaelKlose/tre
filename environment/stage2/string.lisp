;;;; TRE environment
;;;; Copyright (c) 2005-2009,2011 Sven Klose <pixel@copei.de>

(define-test "ELT on string returns char"
  ((characterp (elt "LISP" 0)))
  t)

(define-test "ELT on string returns right char"
  ((= #\L (elt "LISP" 0)))
  t)

;(defun string= (sa sb)
;  "Return T if two strings match."
;  (if (and (string? sa)
;		   (string? sb))
;    (let* ((la (length sa))
;	       (lb (length sb)))
;      (when (= la lb)
;        (dotimes (i la t)
;          (unless (eql (elt sa i) (elt sb i))
;            (return nil)))))
;    (eql sa sb)))

(define-test "STRING= works"
  ((and (string= "abc" "abc")
        (not (string= "ABC" "abc"))
        (not (string= "abc" "abcd"))
        (not (string= "abcd" "abc"))))
  t)

;(define-test "STRING= is safe"
;  ((and (string= nil nil)
;        (string= 1 1)
;	(string= #'eq #'eq)))
;  t)

(define-test "LIST-STRING works"
  ((string= (list-string '(#\L #\I #\S #\P))
	        "LISP"))
  t)

(defun string-list (x)
  (let* ((l (length x))
		 (s))
    (do ((i (integer-1- l) (integer-1- i)))
		((integer< i 0))
      (setf s (push (elt x i) s)))
	s))

(define-test "STRING-LIST works"
  ((equal (string-list "LISP") '(#\L #\I #\S #\P)))
  t)

(defun queue-string (x)
  (list-string (queue-list x)))

(defun string-upcase (str)
  (when str
    (let* ((n (length str))
           (s (make-string 0)))
      (do ((i 0 (integer-1+ i)))
          ((integer= i n) s)
        (setf s (+ s (string (char-upcase (elt str i)))))))))

(define-test "STRING-UPCASE works"
  ((string= (string-upcase "lisp")
	    "LISP"))
  t)

(defun string-downcase (str)
  (when str
    (let* ((n (length str))
           (s (make-string 0)))
      (do ((i 0 (integer-1+ i)))
          ((integer= i n) s)
        (setf s (+ s (string (char-downcase (elt str i)))))))))

(define-test "STRING-DOWNCASE works"
  ((string= (string-downcase "LISP")
	    "lisp"))
  t)

(defun char-code (chr)
  (integer chr))
