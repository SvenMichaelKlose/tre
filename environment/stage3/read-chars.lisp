; tré - Copyright (c) 2016 Sven Michael Klose <pixel@hugbox.org>

(defun read-chars (in num)
  (list-string (maptimes [read-char in] num)))
