(define-test "LIST? for cell"
  ((list? '(1)))
  t)

(define-test "LIST? for NIL"
  ((list? nil))
  t)

(define-test "LIST? fails with number"
  ((list? 1))
  nil)

(define-test "LIST? fails with symbol"
  ((list? 'a))
  nil)
