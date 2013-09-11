;;;;; tré – Copyright (c) 2008,2013 Sven Michael Klose <pixel@copei.de>

(defun string-integer (str)
  (alet (make-string-stream)
    (format ! "~A" str)
    (read-integer !)))
