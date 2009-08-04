;;;;; TRE environment
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defun force-downcase-string (x)
  (if (stringp x)
	  x
	  (string-downcase (symbol-name x))))
