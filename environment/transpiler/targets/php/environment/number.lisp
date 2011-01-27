;;;;; Transpiler: TRE to PHP
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(dont-obfuscate is_int is_float)

(defun %number? (x)
  (or (is_int x)
      (is_float x)))

(defun number (x)
  (%transpiler-native "__w((float)" x ")"))
