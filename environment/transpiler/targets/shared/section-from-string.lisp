(fn section-from-string (name str)
  (. name (read-from-string str)))
