;;;;; tré – Copyright (C) 2005–2009,2011–2012 Sven Michael Klose <pixel@copei.de>

(defun (= symbol-function) (fun sym)
  (%set-atom-fun sym fun)
  fun)
