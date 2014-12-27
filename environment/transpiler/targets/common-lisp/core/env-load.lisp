; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(defvar *environment-path* ".")
(defvar *environment-filenames* nil)

(defbuiltin env-load (pathname &optional (target nil))
  (setq *environment-filenames* (cons (cons pathname target) *environment-filenames*))
  (%load (string-concat *environment-path* "/environment/" pathname)))
