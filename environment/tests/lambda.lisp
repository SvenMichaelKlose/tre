(deftest "LAMBDA? works with no LAMBDA symbol"
  ((unnamed-lambda? '#'((x) x)))
  t)

(deftest "LAMBDA? works with LAMBDA with no LAMBDA symbol"
  ((unnamed-lambda? '#'(lambda (x) x)))
  t)

(deftest "LAMBDA-CALL? works"
  ((lambda-call? '(#'((x) x) nil)))
  t)
