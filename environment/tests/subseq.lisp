(deftest "LIST-SUBSEQ work at the beginning"
  ((list-subseq '(a b c) 0 1))
  '(a))

(deftest "LIST-SUBSEQ works in the middle"
  ((list-subseq '(1 2 3 4) 1 3))
  '(2 3))

(deftest "LIST-SUBSEQ works at the end"
  ((list-subseq '(1 2 3 4) 2))
  '(3 4))

(deftest "SUBSEQ returns head"
  ((subseq "lisp" 1))
  "isp")

(deftest "SUBSEQ returns NIL when totally out of range"
  ((subseq "lisp" 10))
  nil)

(deftest "SUBSEQ returns NIL when start and end are the same"
  ((not (subseq "lisp" 1 1)))
  t)
