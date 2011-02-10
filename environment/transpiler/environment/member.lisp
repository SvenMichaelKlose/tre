;;;;; TRE environment
;;;;; Copyright (C) 2005-2006,2008,2011 Sven Klose <pixel@copei.de>

(defun %member-r (elm lst)
  (while lst
         nil
    (when (equal elm lst.)
	  (return lst))
    (setf lst .lst)))

(defun member (elm &rest lsts)
  (dolist (i lsts)
    (awhen (%member-r elm i)
	  (return !))))
