(fn print (x &optional (str *standard-output*))
  (late-print x str))

(fn force-output (&optional (str *standard-output*)))

(fn %print-get-args (args def))

(fn princ-number (x str)
  (stream-princ (string x) str))
