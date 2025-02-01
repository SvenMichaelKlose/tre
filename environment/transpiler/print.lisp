(fn %print-note (fmt args)
  (princ "; ")
  (*> #'format t fmt args))

(fn print-note (fmt &rest args)
  (& *print-notes?*
     (%print-note fmt args)))

(fn print-status (fmt &rest args)
  (& *print-status?*
     (%print-note fmt args)))

(fn developer-note (fmt &rest args)
  (& *development?*
     (%print-note fmt args)))
