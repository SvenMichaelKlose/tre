; tré – Copyright (c) 2008–2014 Sven Michael Klose <pixel@copei.de>

(defun funinfo-comment (fi)
  (? (funinfo-comments?)
        `("/*" ,*newline*
          ,(print-funinfo fi nil)
          "*/" ,*newline*)
     ""))
