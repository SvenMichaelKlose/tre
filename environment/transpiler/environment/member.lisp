;;;;; tré – Copyright (c) 2005–2006,2008,2011–2012 Sven Michael Klose <pixel@copei.de>

(defun %member-r (elm lst)
  (while lst
         nil
    (when (eql elm lst.)
	  (return lst))
    (= lst .lst)))

(defun member (elm &rest lsts)
  (dolist (i lsts)
    (awhen (%member-r elm i)
	  (return !))))
