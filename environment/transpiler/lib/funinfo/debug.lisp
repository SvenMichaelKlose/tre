;;;;; tré – Copyright (C) 2006–2007,2009,2012–2013 Sven Michael Klose <pixel@copei.de>

;;;; DEBUG PRINTERS

(defun only-element-or-all-of (x)
  (? .x x x.))

(defun human-readable-funinfo-names (fi)
  (only-element-or-all-of (butlast (funinfo-names fi))))

(defun print-funinfo (fi &optional (str nil))
  (with-default-stream s str
    (format s (concat-stringtree
                  (filter [!? ._.
                              (format s "  ~A~A~%" _. !)
                              !]
                          `(("Scope:           " ,(human-readable-funinfo-names fi))
                            ("Argument def:    " ,(| (funinfo-argdef fi)
                                                     "no arguments"))
                            ("CPS transformed: " ,(funinfo-cps? fi))
                            ("Expanded args:   " ,(funinfo-args fi))
                            ("Local vars:      " ,(funinfo-vars fi))
                            ("Used vars:       " ,(funinfo-used-vars fi))
                            ("Free vars:       " ,(funinfo-free-vars fi))
                            ("Places:          " ,(funinfo-places fi))
                            ("Globals:         " ,(funinfo-globals fi))
                            ("Local funs:      " ,(funinfo-local-function-args fi))
                            ("Ghost:           " ,(funinfo-ghost fi))
                            ("Scope:           " ,(funinfo-scope fi))
                            ("Scoped vars:     " ,(funinfo-scoped-vars fi))))))))

(defun print-funinfo-stack (fi &key (include-global? nil))
  (when fi
    (print-funinfo fi)
    (print-funinfo-stack (funinfo-parent fi) :include-global? include-global?))
  fi)
