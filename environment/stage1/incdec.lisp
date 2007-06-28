;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005 Sven Klose <pixel@copei.de>
;;;;
;;;; Increment/decrement functions

(defmacro incf (place &optional (n 1))
  `(setf ,place (+ ,place ,n)))

(defmacro decf (place &optional (n 1))
  `(setf ,place (+ ,place ,n)))
