;;;;; TRE environment
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(defun count-if (pred lst &optional (init 0))
  (if lst
	  (count-if pred .lst (integer+ (if (funcall pred lst.)
								 		1
								 		0)
 							 init))
	  init))

(define-test "COUNT-IF"
  ((count-if #'numberp '(1 b 1 c 1 d)))
  3)
