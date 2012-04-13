;;;;; tré - Copyright (c) 2005-2009,2011-2012 Sven Michael Klose <pixel@copei.de>

(functional nth copy-list)

(%defun nth (i c)
  (? c
     (? (integer> i 0)
	    (nth (integer- i 1) (cdr c))
        (car c))))

(%defun copy-list (c)
  (? c
     (? (cons? c)
	    (cons (car c) (copy-list (cdr c)))
        (progn
          (print c)
          (%error "COPY-LIST: cons expected")))))
