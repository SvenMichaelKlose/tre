;;;;; Transpiler: TRE to PHP
;;;;; Copyright (c) 2011 Sven Klose <pixel@copei.de>

(dont-obfuscate is_object isset function_exists)

(defun objectp (x)
  (is_object x))

(defun functionp (x)
  (function_exists x))
