;;;;; tré – Copyright (c) 2011,2013 Sven Michael Klose <pixel@copei.de>

(defvar *native-eval-return-value* nil)

(defun native-eval (str)
  (unless (string? str)
    (late-print 'not-a-string)
    (late-print str))
  (%%%eval (late-print (+ (obfuscated-identifier '*native-eval-return-value*) "=" str ";")))
  *native-eval-return-value*)
