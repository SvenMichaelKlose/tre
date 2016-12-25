(define-test "INTEGER- literal"
  ((== 1 (- 66 65)))
  t)

(define-test "INTEGER+ literal"
  ((== 66 (integer+ 65 1)))
  t)

(define-test "INTEGER== to be T"
  ((integer== 0 0))
  t)

(define-test "INTEGER== to be NIL"
  ((integer== 0 1))
  nil)

(define-test "INTEGER> to be T"
  ((integer> 1 0))
  t)

(define-test "INTEGER> to be NIL"
  ((integer> 0 1))
  nil)

(define-test "INTEGER< to be T"
  ((integer< 0 1))
  t)

(define-test "INTEGER< to be NIL"
  ((integer< 1 0))
  nil)
