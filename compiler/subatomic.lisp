;;;; nix operating system project
;;;; lisp compiler
;;;; Copyright (c) 2006-2007 Sven Klose <pixel@copei.de>
;;;;
;;;; Subatomic expression utilities.

(defun vm-scope? (e)
  (and (consp e) (eq 'VM-SCOPE (car e))))

(defun vm-go? (e)
  (and (consp e) (eq 'VM-GO (car e))))

(defun vm-go-nil? (e)
  (and (consp e) (eq 'VM-GO-NIL (car e))))

(defun vm-jump? (e)
  (and (consp e) (in? (car e) 'VM-GO 'VM-GO-NIL)))

(defun vm-scope-body (x)
  (cdr x))

(defun expex-sym? (x)
  (and (atom x)
	   (string= "~E" (subseq (symbol-name x) 0 2))))

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

(defun %setq-place (x)
  (second x))

(defun %setq-value (x)
  (third x))
