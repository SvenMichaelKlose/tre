;;;;; tré – Copyright (c) 2010,2012 Sven Michael Klose <pixel@copei.de>

(defun find-all-if (pred &rest lists)
  (apply #'remove-if [not (funcall pred _)] lists))
