(fn quoted (x)
  (+ "\"" (escape-string x) "\""))

(fn single-quoted (x)
  (+ "'" (escape-string x #\' #\') "'"))
