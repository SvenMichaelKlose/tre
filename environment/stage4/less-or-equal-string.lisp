;;;;; TRE environment
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defun <=-string (a b)
  (<=-list (string-list a)
		   (string-list b)))
