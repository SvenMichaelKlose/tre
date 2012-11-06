;;;;; tré – Copyright (c) 2008,2011–2012 Sven Michael Klose <pixel@copei.de>

(defun force-tree (x)
  (list-unless [cons? _.] x))
