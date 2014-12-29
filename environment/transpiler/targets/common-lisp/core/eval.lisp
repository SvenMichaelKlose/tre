; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

; Usually every function keeps its source code.
; If we do this in SBCL, anonymous functions won't get garbage collected,
; That's why it's disabled here.
(defconstant +anonymous-function-sources?+ nil)

(defun make-scoping-function (x)
  (with-gensym g
    `(labels ((,g ,@(make-lambdas (cadar x))))
       (,g ,@(make-lambdas .x)))))

(defun make-anonymous-function (x)
  (? +anonymous-function-sources?+
     (with-gensym g
       `(cl:let ((,g #'(lambda ,@(make-lambdas .x.)))
          (cl:setf (cl:gethash ~anonymous-fun *function-atom-sources*) ',.x.)
          ,g)))
     `#'(lambda ,@(make-lambdas .x.))))

(defun lambda-expr-without-lambda-keyword? (x)
  (& (cons? x)
     (eq 'function x.)
     (not (atom .x.))
     (not (eq 'lambda (car .x.)))))

(defun make-lambdas (x)
  (cond
    ((atom x)           (? (symbol? x)
                           (? (equal "&BODY" (symbol-name x))
                              (make-symbol (symbol-name x) "TRE")
                              x)
                           x))
    ((eq 'quote x.)     x)
    ((lambda-expr-without-lambda-keyword? x.) (make-scoping-function x))
    ((lambda-expr-without-lambda-keyword? x)  (make-anonymous-function x))
    (t (cl:mapcar #'make-lambdas x))))

(defun tre2cl (x)
  (make-lambdas (backquote-expand (specialexpand (car (backquote-expand (list x)))))))

(defbuiltin eval (x)
  (cl:eval (tre2cl x)))
