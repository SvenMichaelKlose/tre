(fn number-not-character? (x)
  (& (not (character? x))
     (number? x)))

(fn princ (x &optional (str *standard-output*))
  (with-default-stream s str
    (?
      (number-not-character? x)  (princ-number x s)
      (symbol? x)                (stream-princ (symbol-name x) s)
      (stream-princ x s))
	x))
