;;;;; tré - Copyright (c) 2008-2009,2011 Sven Klose <pixel@copei.de>

(defun eql (x y)
  (unless x			; Convert falsity to 'null'.
	(setq x nil))
  (unless y
	(setq y nil))
  (or (%%%eq x y)
      (? (or (number? x) (number? y))
         (?
           (and (integer? x) (integer? y))
	         (integer= x y)
           (and (character? x) (character? y))
	         (character= x y))
	    (= x y))))
