;;;;; tré – Copyright (c) 2005–2008,2010,2012–2014 Sven Michael Klose <pixel@hugbox.org>

(defun fresh-line? (&optional (str *standard-output*))
  (== (stream-last-char str) (code-char 10)))

(defun end-of-file? (&optional (str *standard-input*))
  (!? (stream-fun-eof str)
      (funcall ! str)))
