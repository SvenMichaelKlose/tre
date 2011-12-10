;;;;; tré - Copyright (c) 2011 Sven Klose <pixel@copei.de>

(defvar *native-eval-return-value* nil)

(defun native-eval (str)
  (unless (string? str)
    (late-print 'not-a-string)
    (late-print str))
  (%%%eval (late-print (+ (transpiler-symbol-string *js-transpiler* '*native-eval-return-value*) "=" str ";")))
  *native-eval-return-value*)
