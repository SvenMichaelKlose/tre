(defun %error (msg)
  (princ msg)
  (invoke-debugger)
  nil)

(defun error (fmt &rest args)
  (%error (format nil "Error: ~A~%" (apply #'format nil fmt args))))
