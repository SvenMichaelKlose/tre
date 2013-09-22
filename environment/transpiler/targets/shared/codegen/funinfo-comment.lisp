;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun only-element-or-all-of (x)
  (? .x x x.))

(defun funinfo-comment (fi)
   (concat-stringtree
      `("/*" ,*newline*
        ,@(filter [!? ._.
                      (format nil "  ~A~A~%" _. !)
                      !]
                  `(("Scope:           " ,(only-element-or-all-of (butlast (funinfo-names fi))))
                    ("Argument def:    " ,(| (funinfo-argdef fi)
                                             "no arguments"))
                    ("CPS transformed: " ,(funinfo-cps? fi))
                    ("Expanded args:   " ,(funinfo-args fi))
                    ("Local vars:      " ,(funinfo-vars fi))
                    ("Used vars:       " ,(funinfo-used-vars fi))
                    ("Free vars:       " ,(funinfo-free-vars fi))
                    ("Globals:         " ,(funinfo-globals fi))
                    ("Local funs:      " ,(funinfo-local-function-args fi))
                    ("Immutables:      " ,(funinfo-immutables fi))
                    ("Ghost:           " ,(funinfo-ghost fi))
                    ("Lexical:         " ,(funinfo-lexical fi))
                    ("Lexicals:        " ,(funinfo-lexicals fi))))
        "*/" ,*newline*)))
