; tré – Copyright (c) 2014–2015 Sven Michael Klose <pixel@hugbox.org>

(defvar *environment-path* ".")
(defvar *environment-filenames* nil)

(defbuiltin env-load (pathname &rest targets)
  (print-definition `(env-load ,pathname ,@targets))
  (setq *environment-filenames* (. (. pathname targets) *environment-filenames*))
  (when (| (not targets)
           (member :cl targets))
    (load (+ *environment-path* "/environment/" pathname))))
