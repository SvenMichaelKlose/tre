;;;;; tré – Copyright (c) 2008,2011–2013 Sven Michael Klose <pixel@copei.de>

(defun ensure-tree (x)
  (list-unless [cons? _.] x))
