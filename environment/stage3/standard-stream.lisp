(fn make-standard-stream ()
  (make-stream
      :fun-in  [%read-char nil]
      :fun-out #'((c str) (%princ c nil))
      :fun-eof [%feof nil]))

(defvar *standard-output* (make-standard-stream))
(defvar *standard-input* (make-standard-stream))
(defvar *standard-error* (make-standard-stream))
