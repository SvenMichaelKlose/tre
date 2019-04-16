(deftest "MEMBER finds elements"
  ((? (member 's '(l i s p))
      t))
  t)

(deftest "MEMBER finds elements with user predicate"
  ((? (member "lisp" '("tre" "lisp") :test #'string==)
      t))
  t)

(deftest "MEMBER falsely detects foureign elements"
  ((member 'a '(l i s p)))
  nil)
