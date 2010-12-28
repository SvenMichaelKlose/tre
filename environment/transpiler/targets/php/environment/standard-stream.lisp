;;;;; TRE environment
;;;;; Copyright (c) 2009-2010 Sven Klose <pixel@copei.de>

(dont-obfuscate echo)

(defun make-standard-stream ()
  (make-stream
      :fun-in       #'((str))
      :fun-out      #'((c str)
                         (%setq nil (echo (if (stringp c)
											  c
											  (char-string c))))
                         nil)
	  :fun-eof	  #'((str) t)))

(defvar *standard-output* (make-standard-stream))
(defvar *standard-input* (make-standard-stream))
