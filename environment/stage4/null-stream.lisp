;;;; TRE environment
;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;
;;;; Stream that does nothing.

(defun make-null-stream ()
  (make-stream
    :fun-in       #'((str))
    :fun-out      #'((c str) (logwindow.document.write str))
	:fun-eof	  #'((str))))
