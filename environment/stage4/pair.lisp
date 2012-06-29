;;;;; tré – Copyright (c) 2009,2011–2012 Sven Michael Klose <pixel@copei.de>

(defun pair? (x)
  (& (cons? x)
     .x
     (atom .x)))
