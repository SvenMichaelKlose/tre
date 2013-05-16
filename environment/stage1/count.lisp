;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(functional count)

(early-defun count-r (x lst init)
  (? lst
     (? (eq x (car lst))
	    (count-r x (cdr lst) (integer+ 1 init))
	    (count-r x (cdr lst) init))
     init))

(early-defun count (x lst)
  (count-r x lst 0))

(define-test "COUNT"
  ((count 'a '(a b a c a d)))
  3)
