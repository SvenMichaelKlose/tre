; tré – Copyright (c) 2014 Sven Michael Klose <pixel@hugbox.org>

(defun %print-note (fmt &rest args)
  (fresh-line)
  (princ "; ")
  (apply #'format t fmt args))

(defun print-note (fmt &rest args)
  (& *print-notes?*
     (apply #'%print-note fmt args)))

(defun print-status (fmt &rest args)
  (& *print-status?*
     (apply #'%print-note fmt args)))

(defun developer-note (fmt &rest args)
  (& *development?*
     (apply #'%print-note fmt args)))
