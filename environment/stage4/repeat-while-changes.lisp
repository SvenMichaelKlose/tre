; tré – Copyright (C) 2008,2012,2015 Sven Michael Klose <pixel@copei.de>

(defun repeat-while-changes (fun x)
  (awhile (funcall fun x)
          x
    (!? (equal x !)
        (return x))
    (= x !)))
