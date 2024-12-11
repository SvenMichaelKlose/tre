(fn human-readable-funinfo-names (fi)
  (reverse (butlast (funinfo-names fi))))

(fn print-funinfo (fi &optional (str nil))
  (with-default-stream s str
    (with (names [& _
                    (+ (*> #'+ (pad (@ #'symbol-name (ensure-list _)) " "))
                       *terpri*)])
      (@ [awhen ._.
           (format s "  ~A~A" _. !)]
         `(("Scope:          " ,(names (human-readable-funinfo-names fi)))
           ("Argument def:   " ,(funinfo-argdef fi))
           ("Args:           " ,(names (funinfo-args fi)))
           ("Scope arg:      " ,(names (funinfo-scope-arg fi)))
           ("Local vars:     " ,(names (funinfo-vars fi)))
           ("Used vars:      " ,(names (funinfo-used-vars fi)))
           ("Free vars:      " ,(names (funinfo-free-vars fi)))
           ("Places:         " ,(names (funinfo-places fi)))
           ("Globals:        " ,(names (funinfo-globals fi)))
           ("Local fun args: " ,(names (funinfo-local-function-args fi)))
           ("Local scope:    " ,(names (funinfo-scope fi)))
           ("Scoped vars:    " ,(names (funinfo-scoped-vars fi))))))))

(fn print-funinfo-stack (fi &key (include-global? nil))
  (when fi
    (print-funinfo fi)
    (print-funinfo-stack (funinfo-parent fi) :include-global? include-global?))
  fi)

(fn funinfo-error (fmt &rest args)
  (error "In scope ~A: ~A"
         (human-readable-funinfo-names *funinfo*)
         (*> #'format nil fmt args)))
