(fn %error (msg)
  (dump msg)
  (invoke-debugger)
  nil)

(fn error (fmt &rest args)
  (%error (format nil "Error: ~A~%" (apply #'format nil fmt args))))
