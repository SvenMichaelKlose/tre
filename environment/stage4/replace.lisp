;;;;; tré – Copyright (c) 2009,2011–2012 Sven Michael Klose <pixel@copei.de>

(defun replace (old-elm new-elm lst &key (test #'eq))
  (mapcar [? (funcall test _ old-elm)
             new-elm
             _]
          lst))

(defun replace-tree (old-elm new-elm lst &key (test #'eq))
  (mapcar [?
            (funcall test _ old-elm) new-elm
            (cons? _)                (replace-tree old-elm new-elm _ :test test)
              _]
          lst))
