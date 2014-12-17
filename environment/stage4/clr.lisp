;;;;; tré – Copyright (C) 2005–2008,2012,2014 Sven Michael Klose <pixel@copei.de>

(defmacro clr (&rest places)
  `(= ,@(mapcan [`(,_ nil)] places)))
