;;;; nix operating system project
;;;; lisp compiler
;;;; Copyright (c) 2006-2008 Sven Klose <pixel@copei.de>

(defun %stack? (x)
  (and (consp x)
	   (eq '%STACK (car x))))

(defun %setq? (x)
  (and (consp x)
	   (eq '%SETQ (car x))))

(defun %setqret? (x)
  (and (consp x)
	   (eq '%SETQ (first x))
	   (eq '~%RET (second x))))

(defun quote? (x)
  (and (consp x)
	   (eq 'QUOTE (car x))))

(defun backquote? (x)
  (and (consp x)
	   (eq 'BACKQUOTE (car x))))

(defun identity? (x)
  (and (consp x)
       (eq 'IDENTITY (car x))))
