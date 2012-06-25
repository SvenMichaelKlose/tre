;;;;; tré – Copyright (c) 2010–2012 Sven Michael Klose <pixel@copei.de>

(defun shared-mapcar (fun &rest lsts)
  `(,(? (== 1 (length lsts))
        'filter
        'mapcar)
        ,fun ,@lsts))
