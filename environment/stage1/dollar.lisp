;;;;; TRE environment
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>

(defun $ (&rest args)
  (make-symbol (apply #'string-concat (mapcar #'string args))))

(define-test "$"
  (($ "DOLLAR-" 'test))
  'dollar-test)
