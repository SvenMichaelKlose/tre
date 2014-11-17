;;;;; tré – Copyright (c) 2005–2014 Sven Michael Klose <pixel@copei.de>

(defun env-load (pathname &optional (target nil))
  (push (cons pathname target) *environment-filenames*)
  (%load (string-concat *environment-path* "/environment/" pathname)))

(env-load "stage0-cl/main.lisp")
(env-load "main.lisp")
