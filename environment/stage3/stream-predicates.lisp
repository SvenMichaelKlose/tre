(defun fresh-line? (&optional (str *standard-output*))
  (alet (stream-output-location str)
    (& (stream-location-track? !)
       (== 1 (stream-location-column !)))))

(defun end-of-file? (&optional (str *standard-input*))
  (!? (stream-fun-eof str)
      (funcall ! str)))
