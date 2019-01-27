(fn make-standard-stream ()
  (make-stream
      :fun-in  [%read-char nil]
      :fun-out #'((c str) (%princ c nil))
      :fun-eof [%feof nil]))

(var *standard-output* (make-standard-stream))
(var *standard-input* (make-standard-stream))
(var *standard-error* (make-standard-stream))
