;;;; nix operating system project
;;;; lisp compiler
;;;; Copyright (c) 2006-2007 Sven Klose <pixel@copei.de>

(defun vm-scope? (e)
  (and (consp e) (eq 'VM-SCOPE (car e))))

(defun vm-go? (e)
  (and (consp e) (eq 'VM-GO (car e))))

(defun vm-go-nil? (e)
  (and (consp e) (eq 'VM-GO-NIL (car e))))

(defun vm-jump? (e)
  (and (consp e) (in? (car e) 'VM-GO 'VM-GO-NIL)))

(defun quote? (x)
  (and (consp x) (eq 'QUOTE (car x))))

(defun backquote? (x)
  (and (consp x) (eq 'BACKQUOTE (car x))))
