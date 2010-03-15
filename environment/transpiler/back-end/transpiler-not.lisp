;;;;; TRE compiler
;;;;; Copyright (c) 2010 Sven Klose <pixel@copei.de>

(defun transpiler-not (x)
  (eq x (transpiler-obfuscate-symbol *current-transpiler* nil)))
