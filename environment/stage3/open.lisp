(fn %fopen-direction (direction)
  (case direction
    'input   "r"
    'output  "w"
    'append  "a"
    (error ":DIRECTION isn't specified.")))

(fn open (path &key direction)
  (!? (%fopen path (%fopen-direction direction))
      (make-file-stream :stream !
                          :input-location (make-stream-location :id path))
      (error "Couldn't open file `~A'." path)))

(fn close (str)
  (%fclose (stream-handle str)))
