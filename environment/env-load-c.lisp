;;;;; tré – Copyright (c) 2005–2014 Sven Michael Klose <pixel@copei.de>

(%defun env-load (path &optional (target nil))
  (setq *environment-filenames* (cons (cons path target) *environment-filenames*))
  (load (string-concat *environment-path* "/environment/" path)))

(env-load "stage0/main.lisp")
(env-load "main.lisp")
