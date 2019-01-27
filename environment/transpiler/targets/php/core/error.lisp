(fn invoke-debugger ()
  (tre_backtrace "INVOKE-DEBUGGER called"))

(fn %error (msg)
  (error_log msg)
  (%princ msg)
  (invoke-debugger))

(fn error (fmt &rest args)
  (%error (+ "Error: " (apply #'format nil fmt args))))
