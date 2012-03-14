;;;;; TRE environment
;;;;; Copyright (c) 2008,2011 Sven Klose <pixel@copei.de>

(defun force-tree (x)
  (list-unless (fn cons? _.) x))
