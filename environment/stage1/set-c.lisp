;;;;; tré - Copyright (C) 2005-2009,2011 Sven Klose <pixel@copei.de>

(defun (setf symbol-function) (fun sym)
  (%set-atom-fun sym fun)
  fun)
