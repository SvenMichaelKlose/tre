;;;;; TRE environment
;;;;; Copyright (c) 2010 Sven Klose <pixel@copei.de>

(defun remove-many (items lst)
  (dolist (i items lst)
	(remove! i lst)))
