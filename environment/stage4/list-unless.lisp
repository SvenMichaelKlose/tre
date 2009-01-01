;;;;; TRE environment
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>

(defun list-unless (fun x)
  (if (funcall fun x)
	  x
	  (list x)))
