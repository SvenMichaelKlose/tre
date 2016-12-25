(defun force-output (&optional (str *standard-output*))
  (%force-output (stream-handle str)))
