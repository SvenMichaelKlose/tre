(defun read-chars (in num)
  (list-string (maptimes [read-char in] num)))
