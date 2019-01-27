(fn upcase (str)
  (list-string (@ #'char-upcase (string-list str))))

(fn downcase (str)
  (list-string (@ #'char-downcase (string-list str))))
