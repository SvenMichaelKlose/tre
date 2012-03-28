;;;; tré - Copyright (c) 2005-2009,2011 Sven Klose <pixel@copei.de>

(functional string-concat string= string-upcase string-downcase list-string string-list queue-string)

(define-test "ELT on string returns char"
  ((character? (elt "LISP" 0)))
  t)

(define-test "ELT on string returns right char"
  ((= #\L (elt "LISP" 0)))
  t)

;(defun string= (sa sb)
;  "Return T if two strings match."
;  (? (and (string? sa)
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
