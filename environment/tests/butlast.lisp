(define-test "BUTLAST basically works"
  ((butlast '(1 2 3)))
  '(1 2))

(define-test "BUTLAST returns NIL for single cons"
  ((butlast '(1)))
  nil)
