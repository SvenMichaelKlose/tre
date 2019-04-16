(deftest "DIGIT-CHAR? #\0"
  ((digit-char? #\0))
  t)

(deftest "DIGIT-CHAR? #\a"
  ((digit-char? #\a))
  nil)
