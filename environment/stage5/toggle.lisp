;;;;; tré – Copyright (c) 2011–2012 Sven Michael Klose <pixel@copei.de>

(defmacro toggle (place)
  `(= ,place (not ,place)))
