; tré – Copyright (c) 2015–2016 Sven Michael Klose <pixel@hugbox.org>

(metacode-walker gather-imports (x)
  :if-setq (with-%= place value x.
             (adolist ((ensure-list value))
                 (add-wanted-function !)
                 (add-wanted-variable !))
             (list x.)))
