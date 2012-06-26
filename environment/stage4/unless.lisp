;;;;; tré – Copyright (c) 2012 Sven Michael Klose <pixel@copei.de>

(defmacro unless! (place &rest body)
  `(unless ,place
     (= ,place t)
     ,@body))
