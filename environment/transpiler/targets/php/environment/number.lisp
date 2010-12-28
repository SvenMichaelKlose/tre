;;;;; Transpiler: TRE to PHP
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

(dont-obfuscate is_numeric is_string)

(defun %numberp (x)
  (and (not (is_string x))
       (is_numeric x)))
