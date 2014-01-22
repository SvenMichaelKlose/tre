;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(def-funinfo make-scope (funinfo)
  `(div :class "scope"
     ,@(filter [`(div :class "variable"
                   (div ,(symbol-name _))
                   (div "not available"))]
               (+ args vars scoped-vars))))
