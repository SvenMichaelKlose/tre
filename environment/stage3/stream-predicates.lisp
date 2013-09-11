;;;;; tré – Copyright (c) 2005–2008,2010,2012–2013 Sven Michael Klose <pixel@copei.de>

(defun fresh-line? (&optional (str *standard-output*))
  (== (stream-last-char str) (code-char 10)))

(defun end-of-file? (&optional (str *standard-input*))
  (!? (stream-fun-eof str)
     (funcall ! str)))
