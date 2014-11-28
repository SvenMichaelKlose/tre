;;;;; tré – Copyright (c) 2005–2006,2012–2014 Sven Michael Klose <pixel@hugbox.org>

(defun make-standard-stream ()
  (make-stream
      :fun-in  #'((str)
                    str
                    (%read-char nil))
      :fun-out #'((c str)
                    str
                    (%princ c nil))
      :fun-eof #'((str)
                    str
                    (%feof nil))))

(defvar *standard-output* (make-standard-stream))
(defvar *standard-input* (make-standard-stream))
(defvar *standard-error* (make-standard-stream))
