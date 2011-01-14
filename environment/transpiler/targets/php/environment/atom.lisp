;;;;; Transpiler: TRE to PHP
;;;;; Copyright (c) 2011 Sven Klose <pixel@copei.de>

(dont-obfuscate is_object)

(defun objectp (x)
  (is_object x))

(dont-obfuscate function_exists)

(defun functionp (x)
  (function_exists x))
