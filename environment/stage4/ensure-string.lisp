;;;;; tré – Copyright (c) 2009,2011,2013 Sven Michael Klose <pixel@copei.de>

(defun ensure-string (x)
  (? (string? x)
	 x
	 (symbol-name x)))
