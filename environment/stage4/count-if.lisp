;;;;; tré – Copyright (c) 2008–2009,2011 Sven Michael Klose <pixel@copei.de>

(defun count-if (pred lst &optional (init 0))
  (? lst
	 (count-if pred .lst (integer+ (? (funcall pred lst.) 1 0) init))
     init))

(define-test "COUNT-IF"
  ((count-if #'number? '(1 b 1 c 1 d)))
  3)
