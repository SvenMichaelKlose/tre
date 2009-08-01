;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(defun atom (x)
  (not (consp x)))

(defun identity (x) x)
