;;;;; tré – Copyright (c) 2005,2008–2010,2012–2013 Sven Michael Klose <pixel@copei.de>

(defmacro ++! (place &optional (n 1))
  `(= ,place (number+ ,place ,n)))

(defmacro --! (place &optional (n 1))
  `(= ,place (- ,place ,n)))

(defmacro integer++! (place &optional (n 1))
  `(= ,place (integer+ ,place ,n)))

(defmacro integer--! (place &optional (n 1))
  `(= ,place (integer- ,place ,n)))
