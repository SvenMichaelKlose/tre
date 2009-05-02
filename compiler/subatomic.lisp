;;;; nix operating system project
;;;; lisp compiler
;;;; Copyright (c) 2006-2009 Sven Klose <pixel@copei.de>
;;;;
;;;; Subatomic expression utilities.

(mapcar-macro x
	'(vm-scope vm-go vm-go-nil
	  %stack %vec %setq)
  `(def-head-predicate ,x))

(defun vm-jump? (e)
  (and (consp e)
	   (in? e. 'VM-GO 'VM-GO-NIL)))

(defun vm-jump-tag (x)
  (if
	(vm-go? x)
	  .x.
	(vm-go-nil? x)
	  ..x.))

(defun vm-scope-body (x)
  .x)

(defun %var? (x)
  (and (consp x)
	   (eq '%VAR x.)
	   (eq nil ..x)))

(defun %setqret? (x)
  (and (consp x)
	   (eq '%SETQ x.)
	   (eq '~%RET .x.)))

(defun %setq-place (x)
  .x.)

(defun %setq-value (x)
  ..x.)
