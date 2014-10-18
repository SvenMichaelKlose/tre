;;;;; tré – Copyright (c) 2008-2009,2011,2013–2014 Sven Michael Klose <pixel@copei.de>

(defun maptree (fun x)
  (? (atom x)
     (funcall fun x)
     (filter [? (cons? _)
                (funcall fun (maptree fun (funcall fun _)))
                (funcall fun _)]
             x)))
