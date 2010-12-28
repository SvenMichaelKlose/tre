;;;;; Transpiler: TRE to PHP
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

(dont-obfuscate is_int is_float)

(defun %numberp (x)
  (or (is_int x)
      (is_float x)))
