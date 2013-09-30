;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun funinfo-comment (fi)
  (? (transpiler-funinfo-comments? *transpiler*)
        `("/*" ,*newline*
          ,(print-funinfo fi nil)
          "*/" ,*newline*)
     ""))
