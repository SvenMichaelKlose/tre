(fn dump (obj &optional (title nil))
  (format "Dump~A:~%" (? title (+ " of " title) ""))
  (print obj))
