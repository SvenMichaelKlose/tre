;;;;; tré – Copyright (c) 2008,2012 Sven Michael Klose <pixel@copei.de>

(defun lexical2 ()
  (labels ((x () 2))
	(unless (== 2 (x))
	  (%error "x not 2"))
	(x)))

(defun lexical-test ()
  (labels ((x (cnt)
				(unless (== 2 (lexical2))
				  (%error "parent x called"))
				1))
	(unless (== 1 (x 23))
	  (%error "x not 1"))))

(lexical-test)
