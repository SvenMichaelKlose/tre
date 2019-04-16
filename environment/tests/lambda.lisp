(deftest "LAMBDA? works"
  ((lambda? '#'((x) x)))
  t)

(deftest "LAMBDA? works with LAMBDA"
  ((lambda? '#'(lambda (x) x)))
  t)

(deftest "LAMBDA-CALL? works"
  ((lambda-call? '(#'((x) x) nil)))
  t)
