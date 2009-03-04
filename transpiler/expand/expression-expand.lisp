;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(defun transpiler-expression-expand (tr x)
  (expression-expand (transpiler-expex tr) x))
