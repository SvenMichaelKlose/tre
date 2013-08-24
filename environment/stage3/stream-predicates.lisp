;;;;; tré – Copyright (c) 2005–2008,2010,2012–2013 Sven Michael Klose <pixel@copei.de>

(defun fresh-line? (&optional (str *standard-output*))
  "Test if stream is at the beginning of a line."
  (== (stream-last-char str) (code-char 10)))

(defun end-of-file? (&optional (str *standard-input*))
  "Test if stream is at file end."
  (& (stream-fun-eof str)
     (funcall (stream-fun-eof str) str)))
