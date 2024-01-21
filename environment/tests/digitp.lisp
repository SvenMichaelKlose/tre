(deftest "DIGIT? #\0"
  ((digit? #\0))
  t)

(deftest "DIGIT? #\a"
  ((digit? #\a))
  nil)
