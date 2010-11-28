;;;;; TRE environment
;;;;; Copyright (C) 2005-2006,2008 Sven Klose <pixel@copei.de>

(defun %member-r (elm lst)
  (dolist (i lst)
    (when (equal elm i)
	  (return i))))

(defun member (elm &rest lsts)
  (dolist (i lsts)
    (awhen (%member-r elm i)
	  (return !))))
