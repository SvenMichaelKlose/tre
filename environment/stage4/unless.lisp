;;;;; tré - Copyright (c) 2012 Sven Michael Klose <pixel@copei.de>

(defmacro unless! (place &rest body)
  `(unless ,place
     (setf ,place t)
     ,@body))
