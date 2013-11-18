;;;;; tré – Copyright (c) 2009,2013 Sven Michael Klose <pixel@copei.de>

(defmacro log-events (&rest x)
  (when *log-events?*
    `(format t ,@x)))
