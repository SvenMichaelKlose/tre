(defbuiltin quit (&optional exit-code)
  (SB-EXT:QUIT :UNIX-STATUS exit-code))
