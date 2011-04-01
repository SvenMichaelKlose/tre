;;;;; Transpiler: TRE to PHP
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(dont-obfuscate sizeof strlen)

(defun length (x)
  (?
    (not x) x
    (cons? x) (%list-length x)
    (string? x) (strlen x)
    (sizeof x)))
