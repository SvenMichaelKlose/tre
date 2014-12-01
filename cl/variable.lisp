;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(in-package :tre-core)

(defvar *variables* nil)

(defmacro %defvar (name &optional (init nil))
  (print `(%defvar ,name))
  `(progn
     (push (cons ',name ',init) *variables*)
     (defvar ,name ,init)))
