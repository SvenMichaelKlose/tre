;;;;; TRE environment
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>

(defun force-list (x)
  (list-unless (fn consp _) x))
