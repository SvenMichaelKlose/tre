;;;;; tré – Copyright (c) 2008–2010,2013 Sven Michael Klose <pixel@copei.de>

(defun pathname-filename (x) ; TODO: Rename to PATH-FILENAME.
  (car (last (path-pathlist x))))
