(defun invoke-debugger ()
  (tre_backtrace "INVOKE-DEBUGGER called"))

(defun %error (msg)
  (error_log msg)
  (%princ msg)
  (invoke-debugger))

(defun error (fmt &rest args)
  (%error (+ "Error: " (apply #'format nil fmt args))))
