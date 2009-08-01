;;;;; nix lisp compiler
;;;;; Copyright (c) 2007,2009 Sven Klose <pixel@copei.de>

(defvar *verbose-compiler* t)

(defun verbose (msg &rest args)
  (when *verbose-compiler*
    (apply #'format t msg args)))

(defun verbose-flush ()
  (when *verbose-compiler*
    (force-output)))
