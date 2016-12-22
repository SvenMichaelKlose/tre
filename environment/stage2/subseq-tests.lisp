; tré – Copyright (c) 2007–2009,2011–2014 Sven Michael Klose <pixel@copei.de>

(define-test "LIST-SUBSEQ work at the beginning"
  ((list-subseq '(a b c) 0 1))
  '(a))

(define-test "LIST-SUBSEQ works in the middle"
  ((list-subseq '(1 2 3 4) 1 3))
  '(2 3))

(define-test "LIST-SUBSEQ works at the end"
  ((list-subseq '(1 2 3 4) 2))
  '(3 4))

(define-test "SUBSEQ returns head"
  ((subseq "lisp" 1))
  "isp")

(define-test "SUBSEQ returns NIL when totally out of range"
  ((subseq "lisp" 10))
  nil)

(define-test "SUBSEQ returns empty string when start and end are the same"
  ((string== "" (subseq "lisp" 1 1)))
  t)
