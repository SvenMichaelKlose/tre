(fn make-standard-stream ()
  (make-stream :fun-in   #'((str))
               :fun-out  #'((c str) (document.write (? (string? c) c (char-string c))))
               :fun-eof  #'((str) t)))

(defvar *standard-output* (make-standard-stream))
(defvar *standard-input*  (make-standard-stream))
