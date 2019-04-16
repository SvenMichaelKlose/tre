(define-test "EQ with symbols"
  ((eq 'x 'x))
  t)

(define-test "EQL with symbols"
  ((eql 'x 'x))
  t)

(define-test "EQL with numbers"
  ((eql 1 1))
  t)
