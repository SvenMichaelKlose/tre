;;;;; tré – Copyright (c) 2005–2009,2011–2013 Sven Michael Klose <pixel@copei.de>

(functional nth copy-list)

(early-defun nth (i x)
  (? x
     (? (integer> i 0)
	    (nth (integer- i 1) (cdr x))
        (car x))))

(early-defun copy-list (x)
  (? (atom x)
     x
     (progn
       (? (cpr x)
          (setq *default-listprop* (cpr x)))
       (#'((p c) (rplacp c p))
         *default-listprop*
	     (cons (car x) (copy-list (cdr x)))))))
