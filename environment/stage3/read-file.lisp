;;;; TRE environment
;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de?

(defun read-file (name)
  "Read one expression from file."
  (with-open-file in-stream (open name :direction 'input)
	(read in-stream)))

(defun read-file-all (name)
  "Read one expression from file."
  (with-open-file in-stream (open name :direction 'input)
	(read-all in-stream)))
