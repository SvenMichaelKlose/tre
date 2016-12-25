(metacode-walker gather-imports (x)
  :if-setq (with-%= place value x.
             (add-wanted-variable place)
             (@ (i (ensure-list value))
               (add-wanted-function i)
               (add-wanted-variable i))
             (list x.)))
