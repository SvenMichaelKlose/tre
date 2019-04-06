(functional equal list? zero? even? odd? end? keyword? sole?)

(fn equal (x y)
  (?
    (| (atom x)
       (atom y))   (eql x y)
    (equal x. y.)  (equal .x .y)))

(fn list? (x)
  (| (cons? x)
     (not x)))

(fn end? (x)
  (eq nil x))

(fn keyword? (x)
  (& (symbol? x)
     (eq *keyword-package* (symbol-package x))))

(fn sole? (x)
  (== 1 (length x)))
