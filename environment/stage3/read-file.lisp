(defun read-file (name)
  "Read all expressions from file."
  (with-open-file in-stream (open name :direction 'input)
	(read-all in-stream)))
