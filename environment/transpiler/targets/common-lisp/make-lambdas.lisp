; tré – Copyright (c) 2014–2015 Sven Michael Klose <pixel@hugbox.org>

; Usually every function keeps its source code.
; If we do this in SBCL, anonymous functions won't get garbage collected,
; That's why it's disabled here.
(defconstant +anonymous-function-sources?+ nil)

(defun make-scoping-function (x)
  (with-gensym g
    `(labels ((,g ,@(make-lambdas (cadar x))))
       (,g ,@(make-lambdas .x)))))

(defun make-anonymous-function (x)
  (alet (make-lambdas .x.)
    (? (equal ! '(nil))
       `(lambda nil nil)
       `(lambda ,@!))))

(defun lambda-expr-without-lambda-keyword? (x)
  (& (cons? x)
     (eq 'function x.)
     (not (atom .x.))
     (not (eq 'lambda (car .x.)))))

(defun make-lambdas (x)
  (?
    (atom x)        (? (symbol? x)
                       (alet (symbol-name x)
                         (?
                           (cl:string= "&BODY" !)        (make-symbol "&REST" "CL")
                           (| (cl:string= "&OPTIONAL" !)
                              (cl:string= "&REST" !)
                              (cl:string= "&KEY" !))     (make-symbol ! "CL")
                           x))
                       x)
    (eq 'quote x.)  x
    (lambda-expr-without-lambda-keyword? x.) (make-scoping-function x)
    (lambda-expr-without-lambda-keyword? x)  (make-anonymous-function x)
    (filter #'make-lambdas x)))
