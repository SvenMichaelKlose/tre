(functional count)

(%defun count-r (x lst init)
  (? lst
     (count-r x .lst (? (eq x lst.)
                        (+ 1 init)
                        init))
     init))

(%defun count (x lst)
  (count-r x lst 0))

(define-test "COUNT"
  ((count 'a '(a b a c a d)))
  3)
