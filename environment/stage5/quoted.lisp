; Caroshi – Copyright (c) 2016 Sven Michael Klose <pixel@hugbox.org>

(defun quoted (x)
  (+ "\"" (escape-string x) "\""))

(defun single-quoted (x)
  (+ "'" (escape-string x #\' #\') "'"))
