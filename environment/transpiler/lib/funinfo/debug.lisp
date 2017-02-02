; TODO: Rename file to 'debug-printers.lisp'.

(fn only-element-or-all-of (x)
  (? .x x x.))

(fn human-readable-funinfo-names (fi)
  (only-element-or-all-of (butlast (funinfo-names fi))))

(fn print-funinfo (fi &optional (str nil))
  (with-default-stream s str
    (format s (concat-stringtree
                  (@ [!? ._.
                         (format s "  ~A~A~%" _. !)
                         !]
                     `(("Scope:           " ,(human-readable-funinfo-names fi))
                       ("Argument def:    " ,(| (funinfo-argdef fi)
                                                "no arguments"))
                       ("Expanded args:   " ,(funinfo-args fi))
                       ("Scope argument:  " ,(funinfo-scope-arg fi))
                       ("Local vars:      " ,(funinfo-vars fi))
                       ("Used vars:       " ,(funinfo-used-vars fi))
                       ("Free vars:       " ,(funinfo-free-vars fi))
                       ("Places:          " ,(funinfo-places fi))
                       ("Globals:         " ,(funinfo-globals fi))
                       ("Local fun args:  " ,(funinfo-local-function-args fi))
                       ("Local scope:     " ,(funinfo-scope fi))
                       ("Scoped vars:     " ,(funinfo-scoped-vars fi))))))))

(fn print-funinfo-stack (fi &key (include-global? nil))
  (when fi
    (print-funinfo fi)
    (print-funinfo-stack (funinfo-parent fi) :include-global? include-global?))
  fi)

(fn funinfo-error (fmt &rest args)
  (error "In scope ~A: ~A"
         (human-readable-funinfo-names *funinfo*)
         (apply #'format nil fmt args)))
