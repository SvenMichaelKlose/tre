;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2006 Sven Klose <pixel@copei.de>

(defmacro in? (obj &rest opts)
  `(or ,@(mapcar #'((x) `(eq ,obj ,x)) opts)))
