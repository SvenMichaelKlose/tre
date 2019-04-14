(define-test "LAMBDA? works"
  ((lambda? '#'((x) x)))
  t)

(define-test "LAMBDA? works with LAMBDA"
  ((lambda? '#'(lambda (x) x)))
  t)

(define-test "LAMBDA-CALL? works"
  ((lambda-call? '(#'((x) x) nil)))
  t)
