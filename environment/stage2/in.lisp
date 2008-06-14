;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2006-2008 Sven Klose <pixel@copei.de>

(defmacro in? (obj &rest lst)
  "Check if obj is EQ to any member of lst."
  `(or ,@(mapcar #'((x) `(eq ,obj ,x)) lst)))

(defmacro in=? (obj &rest lst)
  "Check if obj is = to any member of lst."
  `(or ,@(mapcar #'((x) `(= ,obj ,x)) lst)))
