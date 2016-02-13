; tré – Copyright (c) 2014–2016 Sven Michael Klose <pixel@hugbox.org>

(defvar *environment-path* ".")
(defvar *environment-filenames* nil)

(defbuiltin env-load (pathname &rest targets)
  (print-definition `(env-load ,pathname ,@targets))
  (setq *environment-filenames* (. (. pathname targets) *environment-filenames*))
  (& (member :cl targets)
     (load (+ *environment-path* "/environment/" pathname))))
