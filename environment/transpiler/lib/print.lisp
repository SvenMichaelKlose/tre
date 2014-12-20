;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@hugbox.org>

(defun %print-note (fmt &rest args)
  (fresh-line)
  (princ "; ")
  (apply #'format t fmt args))

(defun print-note (fmt &rest args)
  (& *show-definitions?*
     (apply #'%print-note fmt args)))

(defun print-status (fmt &rest args)
  (& *show-definitions?*
     (apply #'%print-note fmt args)))
