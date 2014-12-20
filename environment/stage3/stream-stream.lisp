;;;; tré – Copyright (c) 2005–2006,2008,2011–2014 Sven Michael Klose <pixel@copei.de>

(defun make-stream-stream (&key stream
                                (input-location (make-stream-location))
                                (output-location (make-stream-location :track? nil)))
  (make-stream
      :handle           stream
      :input-location   input-location
      :output-location  output-location
      :fun-in           [%read-char (stream-handle _)]
      :fun-out          #'((c str) (%princ c (stream-handle str)))
      :fun-eof          [%feof (stream-handle _)]))
