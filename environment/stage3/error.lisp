;;;;; tré – Copyright (c) 2006–2008,2011–2013 Sven Michael Klose <pixel@copei.de>

(defmacro without-automatic-newline (&rest body)
  `(with-temporary *print-automatic-newline?* nil
     ,@body))

(defun error (msg &rest args)
  (without-automatic-newline
    (%error (apply #'format nil msg args))))

(defun warn (msg &rest args)
  (without-automatic-newline
    (apply #'format t (+ "; WARNING: " msg "~%") args)))

(defun hint (msg &rest args)
  (without-automatic-newline
    (apply #'format t (+ "; HINT: " msg "~%") args)))
