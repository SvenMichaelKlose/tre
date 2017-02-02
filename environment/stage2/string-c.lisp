(defun upcase (str)
  (list-string (@ #'char-upcase (string-list str))))

(defun downcase (str)
  (list-string (@ #'char-downcase (string-list str))))
