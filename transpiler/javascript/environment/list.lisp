;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(defun list (&rest x) x)

(defun %list-length (x &optional (n 0))
  (if (consp x)
      (%list-length .x (1+ n))
      n))
