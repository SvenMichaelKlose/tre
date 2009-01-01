;;;;; TRE environment
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>

(defun force-tree (x)
  (list-unless (fn consp _.) x))
