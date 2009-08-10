;;;; TRE environment
;;;; Copyright (c) 2005-2006,2008-2009 Sven Klose <pixel@copei.de>
;;;;
;;;; File streams

(defun %fopen-direction (direction)
  (case direction
    ('input   "r")
    ('output  "w")
    (t	      (%error ":direction not specified"))))

(defun open (path &key direction)
  (alert "OPEN is unsupported"))

(defun close (str)
  (%fclose (stream-handle str)))
