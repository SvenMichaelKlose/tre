;;;;; TRE tree processor environment
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>

(defun random ()
  "Returns random 8 bit integer ranging from 0 to 255."
  (with-open-file in (open "/dev/random" :direction 'input)
	(integer (read-char in))))
