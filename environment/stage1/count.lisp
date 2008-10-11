;;;;; TRE environment
;;;;; Copyright (C) 2008 Sven Klose <pixel@copei.de>

(%defun count (x lst &optional (init 0))
  (cond
	(lst (cond
		   ((eq x (car lst))
		      (count x (cdr lst) (+ 1 init)))
		   (t (count x (cdr lst) init))))
	(t init)))
