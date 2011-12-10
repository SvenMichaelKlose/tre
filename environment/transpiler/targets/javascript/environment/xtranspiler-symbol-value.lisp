;;;;; tré - Copyright (c) 2011 Sven Klose <pixel@copei.de>

(defun xtranspiler-symbol-value (x)
  (native-eval (transpiler-symbol-string *js-transpiler* x)))
