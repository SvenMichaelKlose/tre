;;;;; TRE environment
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defun force-string (x)
  (if (stringp x)
	  x
	  (symbol-name x)))
