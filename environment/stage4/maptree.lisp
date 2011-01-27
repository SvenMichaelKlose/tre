;;;;; TRE environment
;;;;; Copyright (c) 2008-2009,2011 Sven Klose <pixel@copei.de>

(defun maptree (fun tree)
  (? (atom tree)
     (funcall fun tree)
     (mapcar #'((x)
                 (? (cons? x)
                    (funcall fun (maptree fun (funcall fun x)))
                    (funcall fun x)))
             tree)))
