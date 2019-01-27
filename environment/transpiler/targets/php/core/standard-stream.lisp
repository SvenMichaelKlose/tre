(fn make-standard-stream ()
  (make-stream
      :fun-in       #'((str))
      :fun-out      #'((c str)
                         (%= nil (echo (? (string? c) c (char-string c))))
                         nil)
	  :fun-eof	  #'((str) t)))

(var *standard-output* (make-standard-stream))
(var *standard-input*  (make-standard-stream))
