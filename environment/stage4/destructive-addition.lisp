;;;;; TRE environment
;;;;; Copyright (c) 2010 Sven Klose <pixel@copei.de>

(defmacro +! (place &rest vals)
  `(setf ,place (+ ,place ,@vals)))
