;;;;; TRE tree processor environment
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>

(defun random ()
  (with-open-file in (open "/dev/random" :direction 'input)
	(integer (read-char in))))
