(functional copy-tree)

(%defun copy-tree (x)
  (? (atom x)
     x
     {(? (cpr x)
         (setq *default-listprop* (cpr x)))
      (#'((p c)
            (rplacp c (setq *default-listprop* p)))
        *default-listprop*
	    (. (copy-tree x.)
           (copy-tree .x)))}))
