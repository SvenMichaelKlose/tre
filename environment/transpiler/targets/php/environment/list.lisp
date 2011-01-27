;;;;; Transpiler: TRE to PHP
;;;;; Copyright (c) 2008-2009,2011 Sven Klose <pixel@copei.de>

(defun list (&rest x) x)

(defun %list-length (x &optional (n 0))
  (? (cons? x)
     (%list-length .x (1+ n))
     n))
