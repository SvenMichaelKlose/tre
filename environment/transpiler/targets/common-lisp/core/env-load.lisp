; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(in-package :tre-core)

(defvar *environment-path* ".")
(defvar *environment-filenames* nil)

(%defun env-load (pathname &optional (target nil))
  (setq *environment-filenames* (cons (cons pathname target) *environment-filenames*))
  (tre-parallel:%load (string-concat *environment-path* "/environment/" pathname)))
