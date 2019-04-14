(define-test "NOT 0 is NIL"
  ((not 0))
  nil)

(define-test "LENGHT with conses"
  ((length '(1 2 3 4)))
  (integer 4))

(define-test "LENGHT with strings"
  ((length "test"))
  (integer 4))
