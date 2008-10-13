;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005,2008 Sven Klose <pixel@copei.de>
;;;;
;;;; Mathematical functions

(defun abs (x)
  (if (< x 0)
    (- x)
    x))
