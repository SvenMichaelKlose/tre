;;;;; tré – Copyright (c) 2006–2008,2011–2013 Sven Michael Klose <pixel@copei.de>

(defun error (&rest args)
  (%error (apply #'format nil (+ args. "~%") .args)))

(defun warn (&rest args)
  (apply #'format t (string-concat "; WARNING: " args. "~%") .args))

(defun hint (&rest args)
  (apply #'format t (string-concat "; HINT: " args. "~%") .args))
