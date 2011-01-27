;;;;; TRE environment
;;;;; Copyright (c) 2009,2011 Sven Klose <pixel@copei.de>

(defun force-string (x)
  (? (string? x)
	 x
	 (symbol-name x)))
