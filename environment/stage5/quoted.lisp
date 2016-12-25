(defun quoted (x)
  (+ "\"" (escape-string x) "\""))

(defun single-quoted (x)
  (+ "'" (escape-string x #\' #\') "'"))
