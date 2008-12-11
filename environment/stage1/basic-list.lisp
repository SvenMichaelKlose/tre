;;;;; TRE environment
;;;;; Copyright (c) 2005-2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Basic list functions.

(%defun nth (i c)
  (if c
	  (if (> i 0)
		  (nth (- i 1) (cdr c))
          (car c))))

(%defun copy-list (c)
  (if c
	  (cons (car c)
            (copy-list (cdr c)))))
