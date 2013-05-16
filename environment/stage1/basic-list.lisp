;;;;; tré – Copyright (c) 2005–2009,2011–2013 Sven Michael Klose <pixel@copei.de>

(functional nth copy-list)

(early-defun nth (i c)
  (? c
     (? (integer> i 0)
	    (nth (integer- i 1) (cdr c))
        (car c))))

(early-defun copy-list (c)
  (? (atom c)
     c
	 (cons (car c) (copy-list (cdr c)))))
