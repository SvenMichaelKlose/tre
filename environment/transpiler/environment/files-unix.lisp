(defun %fopen-direction (direction)
  (case direction
    'input   "r"
    'output  "w"
    t	      (%error ":DIRECTION isn't specified.")))
