;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(in-package :tre-core)

(defun %load-r (s)
  (when (tre-parallel:peek-char s)
    (cons (print (tre-parallel:read s))
          (%load-r s))))

(defun quasiquote-expand (x)
  (!? *quasiquoteexpand-hook*
      (funcall ! x)
      x))

(defun dot-expand (x)
  (!? *dotexpand-hook*
      (funcall ! x)
      x))

(defun %expand (x)
  (alet (quasiquote-expand (tre:macroexpand (dot-expand x)))
    (? (equal x !)
       x
       (%expand !))))

(defun %load (pathname)
  (print `(%load ,pathname))
  (dolist (i (with-open-file (s pathname)
               (%load-r s)))
    (%eval (%expand i))))

(defvar *environment-path* ".")
(defvar *environment-filenames* nil)

(%defun env-load (pathname &optional (target nil))
  (setq *environment-filenames* (cons (cons pathname target) *environment-filenames*))
  (%load (string-concat *environment-path* "/environment/" pathname)))
