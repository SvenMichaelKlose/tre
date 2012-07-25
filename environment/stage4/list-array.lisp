;;;;; tré – Copyright (c) 2012 Sven Michael Klose <pixel@copei.de>

(defun list-array (x)
  (with (a (make-array (length x))
         idx 0)
    (dolist (i x a)
      (= (aref a idx) i)
      (1+! idx))))
