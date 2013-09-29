;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun only-element-or-all-of (x)
  (? .x x x.))

(defun human-readable-funinfo-names (fi)
  (only-element-or-all-of (butlast (funinfo-names fi))))

(defun funinfo-comment (fi)
  (? (transpiler-funinfo-comments? *transpiler*)
     (concat-stringtree
        `("/*" ,*newline*
          ,@(filter [!? ._.
                        (format nil "  ~A~A~%" _. !)
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
                      ("Lexical:         " ,(funinfo-lexical fi))
                      ("Lexicals:        " ,(funinfo-lexicals fi))))
          "*/" ,*newline*))
     ""))
