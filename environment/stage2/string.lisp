;;;; tré – Copyright (c) 2005–2009,2011–2014 Sven Michael Klose <pixel@copei.de>

(functional string-concat string== string-upcase string-downcase list-string string-list queue-string)

(defun string-list (x)
  (let* ((l (length x))
		 (s))
    (do ((i (integer-- l) (integer-- i)))
		((integer< i 0))
      (= s (push (elt x i) s)))
	s))

(defun queue-string (x)
  (let str ""
    (adolist ((queue-list x) str)
      (= str (string-concat str (?
                                  (string? !)    !
                                  (character? !) (string !)))))))

(define-test "ELT on string returns char"
  ((character? (elt "LISP" 0)))
  t)

(define-test "ELT on string returns right char"
  ((== #\L (elt "LISP" 0)))
  t)

(define-test "STRING== works"
  ((& (string== "abc" "abc")
      (not (string== "ABC" "abc"))
      (not (string== "abc" "abcd"))
      (not (string== "abcd" "abc"))))
  t)

(define-test "LIST-STRING works"
  ((string== (list-string '(#\L #\I #\S #\P))
	        "LISP"))
  t)

(define-test "STRING-LIST works"
  ((equal (string-list "LISP") '(#\L #\I #\S #\P)))
  t)
