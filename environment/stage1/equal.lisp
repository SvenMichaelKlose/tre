(functional equal)

(defun equal (x y)
  (?
	(| (atom x)
       (atom y))   (eql x y)
    (equal x. y.)  (equal .x .y)))

(define-test "EQUAL with CONS"
  ((equal (list 'x) (list 'x)))
  t)

(define-test "EQUAL fails on different lists"
  ((equal '(1 2) '(3 4)))
  nil)
