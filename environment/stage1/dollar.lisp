;;;;; tré - Copyright (c) 2008,2011-2012 Sven Michael Klose <pixel@copei.de>

(functional $)

(defun $ (&rest args)
  (make-symbol (apply #'string-concat (filter #'string args))))
