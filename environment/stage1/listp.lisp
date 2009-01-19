;;;;; TRE environment
;;;;; Copyright (c) 2005,2008-2009 Sven Klose <pixel@copei.de>

;; Return T if argument is a cons or NIL (non-atomic/end of list).
(%defun listp (x)
  (if (consp x)
	  t
      (not x)))

(define-test "LISTP for cell"
  ((listp '(1)))
  t)

(define-test "LISTP for NIL"
  ((listp nil))
  t)

(define-test "LISTP fails with number"
  ((listp 1))
  nil)

(define-test "LISTP fails with symbol"
  ((listp 'a))
  nil)
