;;;;; TRE environment
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(defun maptree (fun tree)
  (if (atom tree)
      (funcall fun tree)
      (mapcar #'((x)
                  (if (consp x)
                      (funcall fun (maptree fun (funcall fun x)))
                      (funcall fun x)))
              tree)))
