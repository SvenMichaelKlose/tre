(functional zero? even? odd? end? keyword? sole?)

(%defun zero? (x)
  (& (number? x)
     (== 0 x)))

(%defun even? (x)
  (== 0 (mod x 2)))

(%defun odd? (x)
  (== 1 (mod x 2)))

(%defun end? (x)
  (eq nil x))

(%defun keyword? (x)
  (& (symbol? x)
     (eq *keyword-package* (symbol-package x))))

(%defun sole? (x)
  (== 1 (length x)))
