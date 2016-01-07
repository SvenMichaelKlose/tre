; tré – Copyright (c) 2005–2015 Sven Michael Klose <pixel@hugbox.org>

(%defun env-load (path &rest targets)
  (setq *environment-filenames* (. (. path targets) *environment-filenames*))
  (load (string-concat *environment-path* "/environment/" path)))

(env-load "stage0/main.lisp")
(env-load "main.lisp")
