(fn human-readable-funinfo-names (fi)
  (reverse (butlast (funinfo-names fi))))

(fn print-funinfo (fi &optional (str nil))
  (with-default-stream s str
    (with (item
             #'((title x)
                 (when x
                   (format s "  ~A" title)
                   (late-print x s))))
      (item "Scope:          " (human-readable-funinfo-names fi))
      (item "Argument def:   " (funinfo-argdef fi))
      (item "Args:           " (funinfo-args fi))
      (item "Scope arg:      " (funinfo-scope-arg fi))
      (item "Local vars:     " (funinfo-vars fi))
      (item "Used vars:      " (funinfo-used-vars fi))
      (item "Free vars:      " (funinfo-free-vars fi))
      (item "Places:         " (funinfo-places fi))
      (item "Globals:        " (funinfo-globals fi))
      (item "Local fun args: " (funinfo-local-function-args fi))
      (item "Local scope:    " (funinfo-scope fi))
      (item "Scoped vars:    " (funinfo-scoped-vars fi)))))

(fn print-funinfo-stack (fi &key (include-global? nil))
  (when fi
    (print-funinfo fi)
    (print-funinfo-stack (funinfo-parent fi) :include-global? include-global?))
  fi)

(fn funinfo-error (fmt &rest args)
  (error "In scope ~A: ~A"
         (human-readable-funinfo-names *funinfo*)
         (*> #'format nil fmt args)))
