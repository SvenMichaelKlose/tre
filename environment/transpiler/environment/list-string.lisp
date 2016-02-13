; tré – Copyright (c) 2005–2009,2011,2015–2016 Sven Michael Klose <pixel@hugbox.org>

(defun list-string-0 (x)
  (apply #'string-concat (@ #'string x)))

(defun list-string (x)
  (apply #'string-concat (@ #'list-string-0 (group x 16384))))
