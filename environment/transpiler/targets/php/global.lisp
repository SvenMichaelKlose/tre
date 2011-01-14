;;;;; TRE transpiler
;;;;; Copyright (c) 2009-2011 Sven Klose <pixel@copei.de>

(defun php-expex-filter (x)
  (? (and (atom x)
          (not (eq '~%RET x))
          (not (funinfo-in-toplevel-env? *expex-funinfo* x))
          (transpiler-defined-variable *php-transpiler* x))
     `(%transpiler-native "$GLOBALS['" ,(transpiler-obfuscated-symbol-string *php-transpiler* x) "']")
     (php-expex-literal x)))
