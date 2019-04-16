(define-test "BACKQUOTE"
  (`(1 2 3))
  `(1 2 3))

(define-test "QUASIQUOTE"
  (`(1 ,2 ,,3 ,,4))
  '(1 2 ,3 ,4))

(define-test "QUASIQUOTE-SPLICE"
  (`(1 ,@'(2) ,,@3 ,,@4))
  '(1 2 ,@3 ,@4))
