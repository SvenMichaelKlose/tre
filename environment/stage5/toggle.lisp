;;;;; TRE environment
;;;;; Copyright (c) 2011 Sven Klose <pixel@copei.de>

(defmacro toggle (place)
  `(setf ,place (not ,place)))
