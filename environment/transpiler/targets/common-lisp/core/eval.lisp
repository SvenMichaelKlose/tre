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
  `(lambda ,@(make-lambdas .x.)))

(defun lambda-expr-without-lambda-keyword? (x)
  (& (cons? x)
     (eq 'function x.)
     (not (atom .x.))
     (not (eq 'lambda (car .x.)))))

(defun make-lambdas (x)
  (?
    (atom x)        (? (symbol? x)
                       (? (equal "&BODY" (symbol-name x))
                          (make-symbol (symbol-name x) "TRE")
                          x)
                       x)
    (eq 'quote x.)  x
    (lambda-expr-without-lambda-keyword? x.) (make-scoping-function x)
    (lambda-expr-without-lambda-keyword? x)  (make-anonymous-function x)
    (cl:mapcar #'make-lambdas x)))

(defun tre2cl (x)
  (print 'tre2cl)
  (print 'quote-expand) (print x) (print (= x (quote-expand x)))
  (print 'specialexpand) (print x) (print (= x (specialexpand x)))
  (print 'quote-expand) (print x) (print (= x (quote-expand x)))
  (print 'make-lambdas) (print x) (print (= x (make-lambdas x))))
;  (make-lambdas (quote-expand (specialexpand (quote-expand x)))))

(defbuiltin eval (x)
  (cl:eval (tre2cl x)))
