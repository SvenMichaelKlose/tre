;;;;; tré - Copyright (c) 2005-2009,2011-2012 Sven Michael Klose <pixel@copei.de>

(functional nth copy-list)

(%defun nth (i c)
  (if c
	  (if (integer> i 0)
		  (nth (integer- i 1) (cdr c))
          (car c))))

(%defun copy-list (c)
  (if c
      (if (cons? c)
	      (cons (car c) (copy-list (cdr c)))
          (%error "COPY-LIST: cons expected"))))
