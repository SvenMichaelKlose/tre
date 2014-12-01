;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(in-package :tre-core)

(defvar *quasiquoteexpand-hook* nil)
(defvar *dotexpand-hook* nil)

(defun function-expr? (x)
  (and (consp x)
       (eq 'function (car x))
       (not (atom (cadr x)))
       (not (eq 'lambda (caadr x)))))

(defun make-lambdas (x)
  (cond
    ((atom x)                  (? (eq '&body x)
                                  '&rest
                                  x))
    ((eq 'quote (car x))       x)
    ((function-expr? (car x))  `(labels ((~ja ,@(make-lambdas (cadar x))))
                                  (~ja ,@(make-lambdas (cdr x)))))
    ((function-expr? x)        `(let ((~jb #'(lambda ,@(make-lambdas (cadr x)))))
                                  (setf (gethash ~jb *function-atom-sources*) ',(cadr x))
                                  ~jb))
    (t (mapcar #'make-lambdas x))))

(defun quasiquote-expand (x)
  (!? *quasiquoteexpand-hook*
      (funcall ! x)
      x))

(defun dot-expand (x)
  (!? *dotexpand-hook*
      (funcall ! x)
      x))

(defun %eval (x)
  (eval (make-lambdas (print (macroexpand (car (backquote-expand (list x))))))))
