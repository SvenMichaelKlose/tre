;;;;; TRE environment
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>

(%defun count (x lst &optional (init 0))
  (if lst
	  (if (eq x (car lst))
		  (count x (cdr lst) (+ 1 init))
		  (count x (cdr lst) init))
	  init))
