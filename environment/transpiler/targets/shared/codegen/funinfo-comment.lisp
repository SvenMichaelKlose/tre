;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun funinfo-comment (fi)
   (concat-stringtree
      `("/*" ,*c-newline*
        ,@(filter [format nil "~A~A~%" _. ._.]
                  `(("  name:          " ,(funinfo-name fi))
                    ("  argdef:        " ,(funinfo-argdef fi))
                    ("  args:          " ,(funinfo-args fi))
                    ("  vars:          " ,(funinfo-vars fi))
                    ("  ghost:         " ,(funinfo-ghost fi))
                    ("  lexical:       " ,(funinfo-lexical fi))
                    ("  lexicals:      " ,(funinfo-lexicals fi))
                    ("  used vars:     " ,(funinfo-used-vars fi))
                    ("  free vars:     " ,(funinfo-free-vars fi))
                    ("  local funs:    " ,(funinfo-local-function-args fi))
                    ("  immutables:    " ,(funinfo-immutables fi))
                    ("  globals:       " ,(funinfo-globals fi))))
        "*/" ,*c-newline*)))
