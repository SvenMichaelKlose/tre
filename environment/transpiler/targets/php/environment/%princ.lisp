;;;;; tré – Copyright (c) 2012–2013 Sven Michael Klose <pixel@copei.de>

(defun %princ (txt &optional (only-standard-output nil))
  (%= nil (echo txt))
  txt)
