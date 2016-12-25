(defun email-domain (x)
  (!? (position #\@ x)
      (subseq x (1+ !))))
