(deftest "EQ with symbols"
  ((eq 'x 'x))
  t)

(deftest "EQL with symbols"
  ((eql 'x 'x))
  t)

(deftest "EQL with numbers"
  ((eql 1 1))
  t)
