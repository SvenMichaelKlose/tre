(fn read-file (name)
  (with-open-file in-stream (open name :direction 'input)
    (read-all in-stream)))
