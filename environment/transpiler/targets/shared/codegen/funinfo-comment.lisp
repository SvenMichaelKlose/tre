(fn funinfo-comment (fi)
  (? (funinfo-comments?)
        `("/*" ,*terpri*
          ,(print-funinfo fi nil)
          "*/" ,*terpri*)
     ""))
