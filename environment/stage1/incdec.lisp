;;;;; tré – Copyright (c) 2005, 2008–2010,2012 Sven Michael Klose <pixel@copei.de>

(defmacro incf (place &optional (n 1))
  `(= ,place (number+ ,place ,n)))

(defmacro decf (place &optional (n 1))
  `(= ,place (- ,place ,n)))

(defmacro 1+! (place &optional (n 1))
  `(incf ,place ,n))

(defmacro 1-! (place &optional (n 1))
  `(decf ,place ,n))

(defmacro integer1+! (place &optional (n 1))
  `(= ,place (integer+ ,place ,n)))

(defmacro integer1-! (place &optional (n 1))
  `(= ,place (integer- ,place ,n)))
