;;;;; TRE environment
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(%defun count (x lst &optional (init 0))
  (if lst
	  (if (eq x (car lst))
		  (count x (cdr lst) (integer+ 1 init))
		  (count x (cdr lst) init))
	  init))

(define-test "COUNT"
  ((count 'a '(a b a c a d)))
  3)
