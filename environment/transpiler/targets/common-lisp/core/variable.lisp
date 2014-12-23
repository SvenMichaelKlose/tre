;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(defvar *variables* nil)
(push '*variables* *universe*)

(defmacro %defvar (name &optional (init nil))
  (print `(%defvar ,name))
  `(progn
     (push (cons ',name ',init) *variables*)
     (defvar ,name ,init)))
