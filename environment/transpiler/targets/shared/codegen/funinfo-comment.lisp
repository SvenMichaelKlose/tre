(defun funinfo-comment (fi)
  (? (funinfo-comments?)
        `("/*" ,*newline*
          ,(print-funinfo fi nil)
          "*/" ,*newline*)
     ""))
