(var *warnings* nil)

(defmacro without-automatic-newline (&body body)
  `(with-temporary *print-automatic-newline?* nil
     (fresh-line)
     ,@body))

(fn error (msg &rest args)
  (without-automatic-newline
    (%error (apply #'format nil msg args))))

(fn warn (msg &rest args)
  (without-automatic-newline
    (push (apply #'format t (+ "; WARNING: " msg "~%") args) *warnings*)))

(fn hint (msg &rest args)
  (without-automatic-newline
    (apply #'format t (+ "; HINT: " msg "~%") args)))
