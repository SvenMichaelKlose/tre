;;;;; tré – Copyright (c) 2010,2012 Sven Michael Klose <pixel@copei.de>

(defun string-has-whitespace? (x)
  (member-if [character<= _ #\ ] (string-list x)))
