;;;;; TRE environment
;;;;; Copyright (c) 2009,2011 Sven Klose <pixel@copei.de>

(defun pair? (x)
  (and (cons? x)
       .x
       (atom .x)))
