;;;;; tré – Copyright (c) 2006–2014 Sven Michael Klose <pixel@hugbox.org>

(defstruct expex
  (argument-filter  #'identity)
  (setter-filter    #'list)
  (inline?          #'((x) x nil))
  (warnings?        t))
