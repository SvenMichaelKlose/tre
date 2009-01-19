;;;;; TRE environment
;;;;; Copyright (C) 2005, 2008-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Increment/decrement functions

(defmacro incf (place &optional (n 1))
  `(setf ,place (number+ ,place ,n)))

(defmacro decf (place &optional (n 1))
  `(setf ,place (- ,place ,n)))

(defmacro 1+! (place &optional (n 1))
  `(incf ,place ,n))

(defmacro 1-! (place &optional (n 1))
  `(decf ,place ,n))
