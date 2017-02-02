(fn email-domain (x)
  (!? (position #\@ x)
      (subseq x (1+ !))))
