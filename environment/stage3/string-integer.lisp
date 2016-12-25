(defun string-integer (str)
  (alet (make-string-stream)
    (format ! "~A" str)
    (read-integer !)))
