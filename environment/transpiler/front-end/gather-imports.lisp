; tré – Copyright (c) 2015–2016 Sven Michael Klose <pixel@hugbox.org>

(metacode-walker gather-imports (x)
  :if-setq (with-%= place value x.
             (add-wanted-variable place)
             (@ (i (ensure-list value))
               (add-wanted-function i)
               (add-wanted-variable i))
             (list x.)))
