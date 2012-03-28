;;;;; tré - Copyright (c) 2008,2012 Sven Michael Klose <pixel@copei.de>

(defun list-unless (fun x)
  (? (funcall fun x)
     x
	 (list x)))
