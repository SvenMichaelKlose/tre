(define-test "COUNT-IF"
  ((count-if #'number? '(1 b 1 c 1 d)))
  3)

(define-test "COUNT"
  ((count 'a '(a b a c a d)))
  3)
