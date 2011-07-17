;;;;; TRE environment
;;;;; Copyright (c) 2005-2009,2011 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Basic list functions.

(functional nth copy-list)

(%defun nth (i c)
  (if c
	  (if (integer> i 0)
		  (nth (integer- i 1) (cdr c))
          (car c))))

(%defun copy-list (c)
  (if c
	  (cons (car c)
            (copy-list (cdr c)))))
