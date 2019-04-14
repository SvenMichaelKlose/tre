(define-test "NOT works with NIL"
  ((not nil))
  t)

(define-test "NOT works with T"
  ((not t))
  nil)

(define-test "KEYWORD? recognizes keyword-packaged symbols"
  ((keyword? :lisp))
  t)

(define-test "KEYWORD? works with standard symbols"
  ((keyword? 'lisp))
  nil)
