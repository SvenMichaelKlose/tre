;;;;; tré – Copyright (c) 2008–2009,2011–2012 Sven Michael Klose <pixel@copei.de>

(defun make-log-stream ()
  (make-stream
    :fun-in       #'((str))
    :fun-out      #'((c str)
                       (logwindow-add-string (? (string? c) c (char-string c))))
	:fun-eof	  #'((str) t)))

(defvar *standard-log* (make-log-stream))
(= *standard-output* (make-log-stream))
(= *standard-error* (make-log-stream))
