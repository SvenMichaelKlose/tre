;;;;; TRE environment
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(functional count)

(%defun count-r (x lst init)
  (if lst
	  (if (eq x (car lst))
		  (count-r x (cdr lst) (integer+ 1 init))
		  (count-r x (cdr lst) init))
	  init))

(%defun count (x lst)
  (count-r x lst 0))

(define-test "COUNT"
  ((count 'a '(a b a c a d)))
  3)
