; tré – Copyright (C) 2006–2007,2009,2012–2013,2015–2016 Sven Michael Klose <pixel@copei.de>

; XXX Rename file to 'debug-printers.lisp'.

(defun only-element-or-all-of (x)
  (? .x x x.))

(defun human-readable-funinfo-names (fi)
  (only-element-or-all-of (butlast (funinfo-names fi))))

(defun print-funinfo (fi &optional (str nil))
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

(defun print-funinfo-stack (fi &key (include-global? nil))
  (when fi
    (print-funinfo fi)
    (print-funinfo-stack (funinfo-parent fi) :include-global? include-global?))
  fi)

(defun funinfo-error (fmt &rest args)
  (error "In scope ~A: ~A"
         (human-readable-funinfo-names *funinfo*)
         (apply #'format nil fmt args)))
