;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun funinfo-comment (fi)
   (concat-stringtree
      `("/*" ,*c-newline*
        ,@(filter [!? ._.
                      (format nil "~A~A~%" _. !)
                      !]
                  `(("  name:          " ,(funinfo-name fi))
                    ("  argument def:  " ,(| (funinfo-argdef fi)
                                             "no arguments"))
                    ("  expanded args: " ,(funinfo-args fi))
                    ("  local vars:    " ,(funinfo-vars fi))
                    ("  used vars:     " ,(funinfo-used-vars fi))
                    ("  free vars:     " ,(funinfo-free-vars fi))
                    ("  globals:       " ,(funinfo-globals fi))
                    ("  local funs:    " ,(funinfo-local-function-args fi))
                    ("  immutables:    " ,(funinfo-immutables fi))
                    ,@(& (transpiler-lambda-export? *transpiler*)
                         `(("  ghost:         " ,(funinfo-ghost fi))
                           ("  lexical:       " ,(funinfo-lexical fi))
                           ("  lexicals:      " ,(funinfo-lexicals fi))))))
        "*/" ,*c-newline*)))
