;;;;; tré – Copyright (c) 2010,2012 Sven Michael Klose <pixel@copei.de>

(defun number-sym-0 (x)
  (unless (== 0 x)
	(let m (mod x 24)
	  (cons (+ #\a m)
			(number-sym-0 (/ (- x m) 24))))))

(defun number-sym (x)
  (make-symbol (list-string (nconc (number-sym-0 x) (list #\_)))))
