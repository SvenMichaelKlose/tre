;;;;; tré – Copyright (c) 2005-2006,2012 Sven Michael Klose <pixel@copei.de>

(defun make-standard-stream ()
  (make-stream
      :fun-in  #'((str)
                    (%stream-track-input-location str (%read-char nil)))
      :fun-out #'((c str)
                    (%princ c nil))
      :fun-eof #'((str)
                    (%feof nil))))

(defvar *standard-output* (make-standard-stream))
(defvar *standard-input* (make-standard-stream))
