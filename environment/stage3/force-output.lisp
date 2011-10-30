;;;;; tré - Copyright (c) 2005-2008,2010 Sven Klose <pixel@copei.de>

(defun force-output (&optional (str *standard-output*))
  "Flush buffered output."
  (%force-output (stream-handle str)))
