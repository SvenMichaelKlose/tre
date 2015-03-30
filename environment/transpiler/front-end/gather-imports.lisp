; tré – Copyright (c) 2015 Sven Michael Klose <pixel@hugbox.org>

(metacode-walker gather-imports (x)
  :if-setq (with-%= place value x.
             (? (atom value)
                (add-wanted-variable value))
             (when (cons? value)
               (add-wanted-function value.)
               (adolist (.value)
                 (add-wanted-variable !)))
             (list x.)))
