; tré – Copyright (c) 2012–2014 Sven Michael Klose <pixel@copei.de>

(defun list-array (x)
  (with (a    (make-array (length x))
         idx  0)
    (adolist (x a)
      (= (aref a idx) !)
      (++! idx))))
