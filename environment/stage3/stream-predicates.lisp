; tré – Copyright (c) 2005–2008,2010,2012–2015 Sven Michael Klose <pixel@hugbox.org>

(defun fresh-line? (&optional (str *standard-output*))
  (alet (stream-output-location str)
    (& (stream-location-track? !)
       (== 1 (stream-location-column !)))))

(defun end-of-file? (&optional (str *standard-input*))
  (!? (stream-fun-eof str)
      (funcall ! str)))
