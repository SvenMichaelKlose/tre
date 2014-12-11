;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(in-package :tre-core)

; Usually every function keeps its source code.
; If we do this in SBCL, anonymous functions won't get garbage collected,
; That's why it's disabled here.
(defconstant +anonymous-function-sources?+ nil)

(defvar *quasiquoteexpand-hook* nil)
(defvar *dotexpand-hook* nil)

(defun function-expr? (x)
  (and (consp x)
       (eq 'function (car x))
       (not (atom (cadr x)))
       (not (eq 'lambda (caadr x)))))

(defun make-variable-function (x)
  `(labels ((~local-var-fun ,@(make-lambdas (cadar x))))
     (~local-var-fun ,@(make-lambdas (cdr x)))))

(defun make-anonymous-function (x)
  (? +anonymous-function-sources?+
     `(let ((~anonymous-fun #'(lambda ,@(make-lambdas (cadr x)))))
        (setf (gethash ~anonymous-fun *function-atom-sources*) ',(cadr x))
        ~anonymous-fun)
     `#'(lambda ,@(make-lambdas (cadr x)))))

(defun &body-to-&rest (x)
  (? (eq '&body x)
     '&rest
     x))

(defun make-lambdas (x)
  (cond
    ((atom x)                  (&body-to-&rest x))
    ((eq 'quote (car x))       x)
    ((function-expr? (car x))  (make-variable-function x))
    ((function-expr? x)        (make-anonymous-function x))
    (t (mapcar #'make-lambdas x))))

(defun tre2cl (x)
  (make-lambdas (early-macroexpand (car (backquote-expand (list x))))))

(defun %eval (x)
  (eval (tre2cl x)))
