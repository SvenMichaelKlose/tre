(define-test "MEMBER finds elements"
  ((? (member 's '(l i s p))
	  t))
  t)

(define-test "MEMBER finds elements with user predicate"
  ((? (member "lisp" '("tre" "lisp") :test #'string==)
	  t))
  t)

(define-test "MEMBER falsely detects foureign elements"
  ((member 'A '(l i s p)))
  nil)
