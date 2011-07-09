;;;;; TRE
;;;;; Copyright (c) 2011 Sven Klose <pixel@copei.de>

(defun make-keyword (x)
  (make-symbol (symbol-name x) *keyword-package*))
