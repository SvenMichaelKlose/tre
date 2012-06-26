;;;;; tré – Copyright (c) 2010,2012 Sven Michael Klose <pixel@copei.de>

(defmacro +! (place &rest vals)
  `(= ,place (+ ,place ,@vals)))

(defmacro integer+! (place &rest vals)
  `(= ,place (integer+ ,place ,@vals)))
