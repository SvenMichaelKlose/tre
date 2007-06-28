;;;; nix operating system project
;;;; lisp compiler
;;;; Copyright (c) 2006-2007 Sven Klose <pixel@copei.de>

(defun vm-scope? (e)
  (and (consp e) (eq 'vm-scope (car e))))

(defun vm-go? (e)
  (and (consp e) (eq 'vm-go (car e))))

(defun vm-go-nil? (e)
  (and (consp e) (eq 'vm-go-nil (car e))))

(defun vm-jump? (e)
  (and (consp e) (in? (car e) 'vm-go 'vm-go-nil)))
