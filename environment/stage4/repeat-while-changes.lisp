;;;;; tré - Copyright (C) 2008,2012 Sven Michael Klose <pixel@copei.de>

(defun repeat-while-changes (fun x)
  (alet (funcall fun x)
    (? (equal x !)
        x
        (repeat-while-changes fun !))))
