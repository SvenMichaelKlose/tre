;;;;; tré - Copyright (c) 2008-2009,2012,2014 Sven Michael Klose <pixel@hugbox.org>

(defun read-file (name)
  "Read all expressions from file."
  (with-open-file in-stream (open name :direction 'input)
	(read-all in-stream)))
