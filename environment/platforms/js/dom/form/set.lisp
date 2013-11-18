;;;;; tré – Copyright (c) 2009,2012 Sven Michael Klose <pixel@copei.de>

(defun form-rename (x name)
  ((ancestor-or-self-form-element x).set-name name))
