;;;;; TRE environment
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defun replace (old-elm new-elm lst &key (test #'eq))
  (mapcar (fn (if (funcall test _ old-elm)
                  new-elm
                  _))
          lst))
