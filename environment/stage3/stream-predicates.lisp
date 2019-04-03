(fn fresh-line? (&optional (str *standard-output*))
  (!= (stream-output-location str)
    (& (stream-location-track? !)
       (== 1 (stream-location-column !)))))

(fn end-of-file? (&optional (str *standard-input*))
  (!? (stream-fun-eof str)
      (funcall ! str)))
