;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(dont-obfuscate is_number)

(defun numberp (x)
  (is_number x))
