(functional zero? even? odd? end? keyword?)

(fn zero? (x)
  (& (number? x)
     (== 0 x)))

(fn even? (x)
  (== 0 (mod x 2)))

(fn odd? (x)
  (== 1 (mod x 2)))

(fn end? (x)
  (eq nil x))

(fn keyword? (x)
  (& (symbol? x)
     (eq *keyword-package* (symbol-package x))))

(fn sole? (x)
  (== 1 (length x)))

(define-test "NOT works with NIL"
  ((not nil))
  t)

(define-test "NOT works with T"
  ((not t))
  nil)

(define-test "KEYWORDP recognizes keyword-packaged symbols"
  ((keyword? :lisp))
  t)

(define-test "KEYWORDP works with standard symbols"
  ((keyword? 'lisp))
  nil)
