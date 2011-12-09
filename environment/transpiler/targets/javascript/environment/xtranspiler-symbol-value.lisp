;;;;; tré - Copyright (c) 2011 Sven Klose <pixel@copei.de>

(defvar *native-eval-return-value* nil)

(defun xtranspiler-symbol-value (x)
  (%%%eval (+ (transpiler-symbol-string *js-transpiler* '*native-eval-return-value*)
              "="
              (transpiler-symbol-string *js-transpiler* x)
              ";"))
  *native-eval-return-value*)
