;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

(defun list (&rest x) x)

(defun %list-length (x)
  (let len 0
    (while (consp x)
           len
      (setf x .x)
      (1+! len))))
