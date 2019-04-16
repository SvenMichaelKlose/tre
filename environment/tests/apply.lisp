(deftest "APPLY one argument"
  ((apply #'list '(1 2 3)))
  '(1 2 3))

(deftest "APPLY many arguments"
  ((apply #'list 1 '(2 3)))
  '(1 2 3))

(deftest "APPLY many arguments"
  ((apply #'list 1 2 '(3)))
  '(1 2 3))
