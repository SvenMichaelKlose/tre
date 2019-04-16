(deftest "ELT on string returns char"
  ((character? (elt "LISP" 0)))
  t)

(deftest "ELT on string returns right char"
  ((eql #\L (elt "LISP" 0)))
  t)

(deftest "STRING== works"
  ((& (string== "abc" "abc")
      (not (string== "ABC" "abc"))
      (not (string== "abc" "abcd"))
      (not (string== "abcd" "abc"))))
  t)

(deftest "LIST-STRING works"
  ((string== (list-string '(#\L #\I #\S #\P))
            "LISP"))
  t)

(deftest "STRING-LIST works"
  ((equal (string-list "LISP") '(#\L #\I #\S #\P)))
  t)

(deftest "UPCASE works"
  ((string== (upcase "lisp") "LISP"))
  t)

(deftest "DOWNCASE works"
  ((string== (downcase "LISP") "lisp"))
  t)
