; tré – Copyright (c) 2014–2015 Sven Michael Klose <pixel@hugbox.org>

; Usually every function keeps its source code.
; If we do this in SBCL, anonymous functions won't get garbage collected,
; That's why it's disabled here.
(defconstant +anonymous-function-sources?+ nil)

(defun make-scoping-function (x)
  (with-gensym g
    `(labels ((,g ,@(make-lambdas (cl:cadar x))))
       (,g ,@(make-lambdas .x)))))

(defun make-anonymous-function (x)
  (alet (make-lambdas .x.)
    (? (equal ! '(nil))
       `(lambda nil nil)
       `(lambda ,@!))))

(defun lambda-expr-without-lambda-keyword? (x)
  (& (cl:consp x)
     (eq 'function x.)
     (cl:not (cl:atom .x.))
     (cl:not (eq 'lambda (cl:car .x.)))))

(defun make-lambdas (x)
  (?
    (cl:atom x)     (? (cl:symbolp x)
                       (alet (symbol-name x)
                         (?
                           (cl:string= "&BODY" !)         (make-symbol "&REST" "CL")
                           (| (cl:string= "&OPTIONAL" !)
                              (cl:string= "&REST" !)
                              (cl:string= "&KEY" !))      (make-symbol ! "CL")
                           x))
                       x)
    (eq 'quote x.)  x
    (lambda-expr-without-lambda-keyword? x.) (make-scoping-function x)
    (lambda-expr-without-lambda-keyword? x)  (make-anonymous-function x)
    (cl:mapcar #'make-lambdas x)))

(defun tre2cl (x)
  (make-lambdas (quote-expand (specialexpand (quote-expand x)))))

(defbuiltin eval (x)
  (cl:eval (tre2cl x)))
