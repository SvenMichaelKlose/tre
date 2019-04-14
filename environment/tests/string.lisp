(define-test "ELT on string returns char"
  ((character? (elt "LISP" 0)))
  t)

(define-test "ELT on string returns right char"
  ((eql #\L (elt "LISP" 0)))
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

(define-test "UPCASE works"
  ((string== (upcase "lisp") "LISP"))
  t)

(define-test "DOWNCASE works"
  ((string== (downcase "LISP") "lisp"))
  t)
