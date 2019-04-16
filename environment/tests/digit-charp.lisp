(define-test "DIGIT-CHAR? #\0"
  ((digit-char? #\0))
  t)

(define-test "DIGIT-CHAR? #\a"
  ((digit-char? #\a))
  nil)
