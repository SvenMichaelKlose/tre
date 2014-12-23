;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

; Usually every function keeps its source code.
; If we do this in SBCL, anonymous functions won't get garbage collected,
; That's why it's disabled here.
(defconstant +anonymous-function-sources?+ nil)

(defun make-variable-function (x)
  (with-gensym g
    `(labels ((,g ,@(make-lambdas (cadar x))))
       (,g ,@(make-lambdas .x)))))

(defun make-anonymous-function (x)
  (? +anonymous-function-sources?+
     (with-gensym g
       `(cl:let ((,g #'(lambda ,@(make-lambdas .x.)))
          (cl:setf (cl:gethash ~anonymous-fun *function-atom-sources*) ',.x.)
          ,g))
     `#'(lambda ,@(make-lambdas .x.))))

(defun &body-to-&rest (x)
  (? (eq '&body x)
     '&rest
     x))

(defun make-lambdas (x)
  (cond
    ((atom x)           x)
    ((eq 'quote x.)     x)
    ((lambda-expr? x.)  (make-variable-function x))
    ((lambda-expr? x)   (make-anonymous-function x))
    (t (cl:mapcar #'make-lambdas x))))

(defun tre2cl (x)
  (make-lambdas (backquote-expand (early-macroexpand (car (backquote-expand (list x)))))))

(defun eval (x)
  (cl:eval (tre2cl x)))
