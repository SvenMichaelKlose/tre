;;;;; TRE environment
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

(defun symbols-function-exprs (x)
  (mapcar (fn `(function ,_))
		  x))
