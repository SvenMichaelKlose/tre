;;;;; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

(defun function-bytecode (x)
  x.__tre-bytecode)

(defun (= function-bytecode) (v x)
  (| (array? x) (error "array expected"))
  (= x.__tre-bytecode v))
