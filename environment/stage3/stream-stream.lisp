(fn make-stream-stream (&key stream
                             (input-location (make-stream-location))
                             (output-location (make-stream-location)))
  (make-stream
      :handle           stream
      :input-location   input-location
      :output-location  output-location
      :fun-in           [%read-char (stream-handle _)]
      :fun-out          #'((c str) (%princ c (stream-handle str)))
      :fun-eof          [%feof (stream-handle _)]))
