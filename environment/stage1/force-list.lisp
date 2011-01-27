;;;;; TRE environment
;;;;; Copyright (c) 2008,2011 Sven Klose <pixel@copei.de>

(defun force-list (x)
  (? (cons? x) x (list x)))
