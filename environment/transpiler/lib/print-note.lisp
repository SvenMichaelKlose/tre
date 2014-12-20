;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@hugbox.org>

(defun print-note (fmt &rest args)
  (when *show-definitions?*
    (princ "; ")
    (apply #'format t fmt args)))
