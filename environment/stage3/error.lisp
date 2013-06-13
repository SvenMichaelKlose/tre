;;;;; tré – Copyright (c) 2006–2008,2011–2013 Sven Michael Klose <pixel@copei.de>

(defun error (msg &rest args)
  (%error (apply #'format nil (+ msg "~%") args)))

(defun warn (msg &rest args)
  (apply #'format t (+ "; WARNING: " msg "~%") args))

(defun hint (msg &rest args)
  (apply #'format t (+ "; HINT: " msg "~%") args))
