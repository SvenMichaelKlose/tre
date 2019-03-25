(fn path-parent (x)
  (!? (butlast (path-pathlist x))
      (pathlist-path !)))   ; Would return "" otherwise.
