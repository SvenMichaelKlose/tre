(deftest "BUTLAST basically works"
  ((butlast '(1 2 3)))
  '(1 2))

(deftest "BUTLAST returns NIL for single cons"
  ((butlast '(1)))
  nil)
