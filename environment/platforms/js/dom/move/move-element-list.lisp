;;;;; tré – Copyright (c) 2010 Sven Michael Klose <pixel@copei.de>

(defun move-element-list (to nodes)
  (dolist (n nodes)
    (n.remove-without-listeners)
	(to.add n)))
