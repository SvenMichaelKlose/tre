; tré – Copyright (c) 2014–2015 Sven Michael Klose <pixel@copei.de>

(defvar *environment-path* ".")
(defvar *environment-filenames* nil)

(defbuiltin env-load (pathname &optional (target nil))
  (print-definition `(env-load ,pathname ,target))
  (setq *environment-filenames* (. (. pathname target) *environment-filenames*))
  (load (+ *environment-path* "/environment/" pathname)))
