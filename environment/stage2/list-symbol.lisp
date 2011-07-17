;;;;; TRE environment
;;;;; Copyright (c) 2008,2011 Sven Klose <pixel@copei.de>

(functional list-symbol)

(defun list-symbol (x)
  (make-symbol (list-string x)))
