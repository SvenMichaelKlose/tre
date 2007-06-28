;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005-2006 Sven Klose <pixel@copei.de>

(defmacro aif (test then &optional else)
  `(let ((! ,test))
    (if ! ,then , else)))

(defmacro awhen (test &rest body)
  `(let ((! ,test))
    (when ! ,@body)))

(defmacro anif (name test then &optional else)
  `(let ((,name ,test))
    (if ,name ,then , else)))

(defmacro anwhen (name test &rest body)
  `(let ((,name ,test))
    (when ,name ,@body)))
