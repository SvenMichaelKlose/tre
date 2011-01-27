;;;;; TRE environment
;;;;; Copyright (c) 2009,2011 Sven Klose <pixel@copei.de>

(defun force-downcase-string (x)
  (? (string? x)
	 x
	 (string-downcase (symbol-name x))))
