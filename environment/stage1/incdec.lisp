;;;;; TRE environment
;;;;; Copyright (C) 2005, 2008-2010 Sven Klose <pixel@copei.de>

(defmacro incf (place &optional (n 1))
  `(setf ,place (number+ ,place ,n)))

(defmacro decf (place &optional (n 1))
  `(setf ,place (- ,place ,n)))

(defmacro 1+! (place &optional (n 1))
  `(incf ,place ,n))

(defmacro 1-! (place &optional (n 1))
  `(decf ,place ,n))

(defmacro integer1+! (place &optional (n 1))
  `(setf ,place (integer+ ,place ,n)))

(defmacro integer1-! (place &optional (n 1))
  `(setf ,place (integer- ,place ,n)))
