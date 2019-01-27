(fn path-parent (x)
  (!? (butlast (path-pathlist x))   ; TODO: Not conditional.
      (pathlist-path !)))
