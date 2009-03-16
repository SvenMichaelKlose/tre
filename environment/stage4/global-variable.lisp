;;;; TRE environment
;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defun global-variable? (x)
  (assoc x *variables*))
