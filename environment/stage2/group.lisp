;;;;; tré – Copyright (c) 2007,2011–2014 Sven Michael Klose <pixel@copei.de>

(functional group)

(defun group (x size)
  (when x
    (cons (subseq x 0 size)
          (group (nthcdr size x) size))))
