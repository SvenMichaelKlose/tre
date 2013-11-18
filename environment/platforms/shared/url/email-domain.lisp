;;;;; tré – Copyright (c) 2012 Sven Michael Klose <pixel@copei.de>

(defun email-domain (x)
  (!? (position #\@ x)
      (subseq x (1+ !))))
