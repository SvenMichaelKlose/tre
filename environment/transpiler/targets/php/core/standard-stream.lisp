;;;;; tré – Copyright (c) 2009–2013 Sven Michael Klose <pixel@copei.de>

(defun make-standard-stream ()
  (make-stream
      :fun-in       #'((str))
      :fun-out      #'((c str)
                         (%= nil (echo (? (string? c) c (char-string c))))
                         nil)
	  :fun-eof	  #'((str) t)))

(defvar *standard-output* (make-standard-stream))
(defvar *standard-input*  (make-standard-stream))
