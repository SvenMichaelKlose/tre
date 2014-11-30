;;;;; tré – Copyright (c) 2008–2014 Sven Michael Klose <pixel@copei.de>

(functional count)

(%defun count-r (x lst init)
  (? lst
     (count-r x (cdr lst) (? (eq x (car lst))
                             (integer+ 1 init)
                             init))
     init))

(%defun count (x lst)
  (count-r x lst 0))

(define-test "COUNT"
  ((count 'a '(a b a c a d)))
  3)
