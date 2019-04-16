(define-test "APPLY one argument"
  ((apply #'list '(1 2 3)))
  '(1 2 3))

(define-test "APPLY many arguments"
  ((apply #'list 1 '(2 3)))
  '(1 2 3))

(define-test "APPLY many arguments"
  ((apply #'list 1 2 '(3)))
  '(1 2 3))
