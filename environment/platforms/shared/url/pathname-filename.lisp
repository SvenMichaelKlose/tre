;;;;; tré – Copyright (c) 2008–2010,2013 Sven Michael Klose <pixel@copei.de>

(defun pathname-filename (x)
  (car (last (path-pathlist x))))
