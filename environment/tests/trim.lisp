(define-test "TRIM-HEAD works"
  ((trim-head "  " " " :test #'string==))
  nil)

(define-test "TRIM-TAIL works"
  ((trim-tail "  " " " :test #'string==))
  nil)

(define-test "TRIM works"
  ((trim "  " " " :test #'string==))
  nil)
