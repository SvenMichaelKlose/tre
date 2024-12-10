(fn make-standard-stream ()
  (make-stream
      :fun-in  #'((str eof) (%read-char *standard-input* nil))
      :fun-out #'((c str) (%princ c *standard-output*))))

(var *standard-output* (make-standard-stream))
(var *standard-input* (make-standard-stream))
(var *standard-error* (make-standard-stream))
