;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005-2006,2008 Sven Klose <pixel@copei.de>

;; Check if atom is an argument keyword.
(%defun %arg-keyword? (x)
  (cond
    ((eq x '&rest) t)
    ((eq x '&optional) t)
    ((eq x '&key) t)))
