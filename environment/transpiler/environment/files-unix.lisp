;;;; tré – Copyright (c) 2005–2006,2008–2009,2013 Sven Michael Klose <pixel@copei.de>

(defun %fopen-direction (direction)
  (case direction
    'input   "r"
    'output  "w"
    t	      (%error ":DIRECTION isn't specified.")))
