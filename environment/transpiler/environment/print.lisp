;;;;; tré - Copyright (c) 2009,2011 Sven Klose <pixel@copei.de>

(dont-inline print)

(defun print (x &optional (str *standard-output*))
  (late-print x str))

(dont-inline force-output)

(defun force-output (&optional (str *standard-output*)))
