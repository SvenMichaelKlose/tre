;;;;; TRE transpiler environment
;;;;; Copyright (c) 2008-2009,2011 Sven Klose <pixel@copei.de>

(defun eq (x y)
  (%%%eq x y))

(defun eql (x y)
  (unless x			; Convert falsity to 'null'.
	(setq x nil))
  (unless y
	(setq y nil))
  (or (%%%eq x y)
	  (= x y)))
