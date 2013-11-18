;;;;; tré – Copyright (c) 2010–2011,2013 Sven Michael Klose <pixel@copei.de>

(defun path-parent (x)
  (!? (butlast (path-pathlist x))
      (pathlist-path !)))
