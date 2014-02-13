;;;;; tré – Copyright (c) 2005–2009,2011–2013 Sven Michael Klose <pixel@copei.de>

(functional nth)

(early-defun nth (i x)
  (? x
     (? (integer> i 0)
	    (nth (integer- i 1) (cdr x))
        (car x))))
