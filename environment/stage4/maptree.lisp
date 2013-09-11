;;;;; tré – Copyright (c) 2008-2009,2011,2013 Sven Michael Klose <pixel@copei.de>

(defun maptree (fun x)
  (? (atom x)
     (funcall fun x)
     (mapcar [? (cons? _)
                (funcall fun (maptree fun (funcall fun _)))
                (funcall fun _)]
             x)))
