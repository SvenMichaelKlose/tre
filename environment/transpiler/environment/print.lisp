(defun print (x &optional (str *standard-output*))
  (late-print x str))

(defun force-output (&optional (str *standard-output*)))

(defun %print-get-args (args def))

(defun princ-number (x str)
  (stream-princ (string x) str))
