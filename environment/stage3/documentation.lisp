;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005-2006 Sven Klose <pixel@copei.de>
;;;;
;;;; Documentation

(defun documentation (sym)
  "Returns documentation string of function or macro."
  (dolist (i *documentation*)
    (when (eq (car i) sym)
      (return (cdr i)))))
