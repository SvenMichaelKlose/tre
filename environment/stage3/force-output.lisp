;;;;; tré – Copyright (c) 2005–2008,2010,2013 Sven Michael Klose <pixel@copei.de>

(defun force-output (&optional (str *standard-output*))
  (%force-output (stream-handle str)))
