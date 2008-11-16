;;;; TRE environment
;;;; Copyright (C) 2005-2008 Sven Klose <pixel@copei.de>

(defun enqueue-many (q l)
  (dolist (e l)
    (enqueue q e)))
