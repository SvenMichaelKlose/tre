(defvar *log-events?* nil)

(defmacro log-events (&rest x)
  (when *log-events?*
    `(format t ,@x)))
