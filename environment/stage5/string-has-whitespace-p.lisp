;;;;; Caroshi ECMAScript library
;;;;; Copyright (c) 2010 Sven Klose <pixel@copei.de>

(defun string-has-whitespace? (x)
  (member-if (fn character<= _ #\ ) (string-list x)))
