;;;; TRE environment
;;;; Copyright (C) 2008 Sven Klose <pixel@copei.de>

(defun repeat-while-changes (fun x)
 (let y (funcall fun x)
   (if (equal x y)
       x
       (repeat-while-changes fun y))))
