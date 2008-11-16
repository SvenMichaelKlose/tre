;;;;; TRE environment
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>

(defun $ (&rest args)
  "Converts arguments to strings, concatenates them and makes a symbol."
  (make-symbol (apply #'string-concat (mapcar #'string args))))

(define-test "$"
  (($ "DOLLAR-" 'test))
  'dollar-test)
