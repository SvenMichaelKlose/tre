(defstruct expex
  (argument-filter  #'identity)
  (setter-filter    #'list)
  (inline?          #'((x) x nil))
  (warnings?        t))
