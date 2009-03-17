;;;;; TRE transpiler
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defun js-setter-filter (tr x)
  (transpiler-add-wanted-variable tr (second x))
  x)
