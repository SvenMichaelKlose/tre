;;;;; tré – Copyright (c) 2006–2013 Sven Michael Klose <pixel@copei.de>

(defstruct expex
  (argument-filter  #'identity)
  (setter-filter    #'list)
  (inline?          #'((x)))
  (move-lexicals?   nil)
  (warnings?        t))
