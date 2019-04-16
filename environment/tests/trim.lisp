(deftest "TRIM-HEAD works"
  ((trim-head "  " " " :test #'string==))
  nil)

(deftest "TRIM-TAIL works"
  ((trim-tail "  " " " :test #'string==))
  nil)

(deftest "TRIM works"
  ((trim "  " " " :test #'string==))
  nil)
