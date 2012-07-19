;;;;; tré – Copyright (c) 2012 Sven Michael Klose <pixel@copei.de>

(defun funinfo-add-literal (fi x)
  (adjoin! x (funinfo-literals fi))
  x)
