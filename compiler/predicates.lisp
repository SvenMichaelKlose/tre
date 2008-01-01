;;;; nix operating system project
;;;; lisp compiler
;;;; Copyright (c) 2006-2007 Sven Klose <pixel@copei.de>

(defun quote? (x)
  (and (consp x) (eq 'QUOTE (car x))))

(defun backquote? (x)
  (and (consp x) (eq 'BACKQUOTE (car x))))

(defun identity? (x)
  (and (consp x)
       (eq (car x) 'identity)))
