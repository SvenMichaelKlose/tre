(defstruct expex
  (argument-filter  #'identity)
  (setter-filter    #'list)
  (inline?          [])
  (warnings?        t))
