(var *warnings* nil)

(defmacro without-automatic-newline (&body body)
  `(with-temporary *print-automatic-newline?* nil
     (fresh-line)
     ,@body))

(fn %error (msg)
  (break (format nil "In file '~A':~%~A" *load* msg)))

(fn error (msg &rest args)
  (without-automatic-newline
    (%error (*> #'format nil msg args))))

(fn warn (msg &rest args)
  (without-automatic-newline
    (push (*> #'format t (+ "; WARNING: " msg "~%") args)
          *warnings*)))

(fn hint (msg &rest args)
  (without-automatic-newline
    (*> #'format t (+ "; HINT: " msg "~%") args)))
