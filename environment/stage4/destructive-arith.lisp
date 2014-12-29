; tré – Copyright (c) 2010,2012–2013 Sven Michael Klose <pixel@copei.de>

(defmacro +! (place &rest vals)
  `(= ,place (+ ,place ,@vals)))

(defmacro -! (place &rest vals)
  `(= ,place (+ ,place ,@vals)))
