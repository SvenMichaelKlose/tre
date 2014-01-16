;;;;; tré – Copyright (c) 2006–2008,2011–2014 Sven Michael Klose <pixel@copei.de>

(defvar *warnings* nil)

(defmacro without-automatic-newline (&body body)
  `(with-temporary *print-automatic-newline?* nil
     ,@body))

(defun error (msg &rest args)
  (without-automatic-newline
    (%error (apply #'format nil msg args))))

(defun warn (msg &rest args)
  (without-automatic-newline
    (push (apply #'format t (+ "; WARNING: " msg "~%") args) *warnings*)))

(defun hint (msg &rest args)
  (without-automatic-newline
    (apply #'format t (+ "; HINT: " msg "~%") args)))
