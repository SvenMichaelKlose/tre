; tré – Copyright (c) 2009,2013,2015 Sven Michael Klose <pixel@copei.de>

(defvar *log-events?* nil)

(defmacro log-events (&rest x)
  (when *log-events?*
    `(format t ,@x)))
