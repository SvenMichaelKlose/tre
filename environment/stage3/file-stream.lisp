(fn make-file-stream (&key stream
                           (input-location  (make-stream-location))
                           (output-location (make-stream-location)))
  (make-stream
      :handle           stream
      :input-location   input-location
      :output-location  output-location
      :fun-in           #'((str eof) (%read-char (stream-handle _) eof))
      :fun-out          #'((c str)   (%princ c (stream-handle str)))))
