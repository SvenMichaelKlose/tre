;;;;; tré – Copyright (c) 2009,2011,2013–2014 Sven Michael Klose <pixel@copei.de>

(defun print (x &optional (str *standard-output*))
  (late-print x str))

(defun force-output (&optional (str *standard-output*)))

(defun %print-get-args (args def))
