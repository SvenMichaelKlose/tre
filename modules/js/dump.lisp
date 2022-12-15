(fn make-log-stream ()
  (make-stream :fun-in   []
               :fun-out  #'((c str)
                             (dump (? (string? c) c (char-string c))))
               :fun-eof  [identity t]))

(var *standard-log* (make-log-stream))

(fn dump (x &optional (title nil))
  (& title
     (console.log (+ title ":")))
  (console.log x)
  x)
