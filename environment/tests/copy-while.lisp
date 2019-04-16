(deftest "COPY-WHILE"
  ((copy-while #'number? '(1 2 3 a)))
  '(1 2 3))
