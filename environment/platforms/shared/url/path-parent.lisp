(defun path-parent (x)
  (!? (butlast (path-pathlist x))
      (pathlist-path !)))
