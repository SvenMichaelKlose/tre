(deftest "NOT works with NIL"
  ((not nil))
  t)

(deftest "NOT works with T"
  ((not t))
  nil)

(deftest "KEYWORD? recognizes keyword-packaged symbols"
  ((keyword? :lisp))
  t)

(deftest "KEYWORD? works with standard symbols"
  ((keyword? 'lisp))
  nil)
