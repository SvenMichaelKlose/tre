(defun %fopen-direction (direction)
  (case direction
    'input   "r"
    'output  "w"
    'append  "a"
    (error ":DIRECTION isn't specified.")))

(defun open (path &key direction)
  (!? (%fopen path (%fopen-direction direction))
      (make-stream-stream :stream !
                          :input-location (make-stream-location :id path))
      (error "Couldn't open file `~A'." path)))

(defun close (str)
  (%fclose (stream-handle str)))
