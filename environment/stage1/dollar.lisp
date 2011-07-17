;;;;; TRE environment
;;;;; Copyright (c) 2008,2011 Sven Klose <pixel@copei.de>

(functional $)

(defun $ (&rest args)
  (make-symbol (apply #'string-concat (mapcar #'string args))))

(define-test "$"
  (($ "DOLLAR-" 'test))
  'dollar-test)
