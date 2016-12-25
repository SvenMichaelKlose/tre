(functional reverse)

(defun reverse (lst)
  (alet nil
    (@ (i lst !)
      (push i !))))

(define-test "REVERSE works"
  ((reverse '(1 2 3)))
  '(3 2 1))
