;;;;; tré – Copyright (c) 2009–2014 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate process stdin stdout read write set-encoding)

(when (defined? process)
  (process.stdin.set-encoding "utf-8"))

(defun make-standard-stream ()
  (make-stream
      :fun-in  #'((str))
      :fun-out #'((c str)
                   (? (defined? process)
                      (%= nil (process.stdout.write (string c)))
                      (%= nil (document.write (string c))))
                   nil)
      :fun-eof #'((str) t)))

(defvar *standard-output* (make-standard-stream))
(defvar *standard-input*  (make-standard-stream))
