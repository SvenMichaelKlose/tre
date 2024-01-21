(fn print (x &optional (str *standard-output*))
  (late-print x str))

(fn force-output (&optional (str *standard-output*)))

(fn princ-number (x str)
  (stream-princ (string x) str))
