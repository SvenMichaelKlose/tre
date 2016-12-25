(when (defined? process)
  (process.stdin.set-encoding "utf-8"))

(defun make-standard-stream ()
  (make-stream
      :fun-in  #'((str))
      :fun-out #'((x str)
                   (%write-char x))
      :fun-eof #'((str) t)))

(defvar *standard-output* (make-standard-stream))
(defvar *standard-input*  (make-standard-stream))
