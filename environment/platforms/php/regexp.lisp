;;;;; tré – Copyright (c) 2012 Sven Michael Klose <pixel@copei.de>

(defclass *reg-exp (pattern &optional (scope ""))
  (= _pattern pattern
     _scope scope))

(defmember *reg-exp _pattern _scope)

(finalize-class *reg-exp)

(defun regexp-match (reg str)
  (preg_match (+ "/" reg._pattern "/u" reg._scope) str))
