(fn symbol-names (x &key (downcase? nil))
  (@ [? (symbol? _)
        (funcall (? downcase?
                    #'downcase
                    #'identity)
                 (symbol-name _))
        _]
     x))

(fn %print-note (fmt &rest args)
  (princ "; ")
  (apply #'format t fmt args))

(fn print-note (fmt &rest args)
  (& *print-notes?*
     (apply #'%print-note fmt args)))

(fn print-status (fmt &rest args)
  (& *print-status?*
     (apply #'%print-note fmt args)))

(fn developer-note (fmt &rest args)
  (& *development?*
     (apply #'%print-note fmt args)))
