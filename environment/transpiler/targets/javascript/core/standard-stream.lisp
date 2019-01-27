(when (defined? process)
  (process.stdin.set-encoding "utf-8"))

(fn make-standard-stream ()
  (make-stream
      :fun-in  #'((str))
      :fun-out #'((x str)
                   (%write-char x))
      :fun-eof #'((str) t)))

(var *standard-output* (make-standard-stream))
(var *standard-input*  (make-standard-stream))
