(deftest "EQUAL with CONS"
  ((equal (list 'x) (list 'x)))
  t)

(deftest "EQUAL fails on different lists"
  ((equal '(1 2) '(3 4)))
  nil)
