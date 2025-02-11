(fn sharp-quote-w/o-lambda? (x)
  (& (cons? x)
     (eq 'function x.)
     (not (atom .x.))
     (not (eq 'lambda .x..))))

(fn make-scoping-function (x)
  (with-gensym g
    `(labels ((,g ,@(make-lambdas (cadr x.))))
       (,g ,@(make-lambdas .x)))))

(fn make-anonymous-function (x)
  (!= (make-lambdas .x.)
    (? (equal ! '(nil))
       `(lambda nil nil)
       `(lambda ,@!))))

(fn make-lambdas (x)
  (?
    (eq x '&body)  '&rest
    (atom x)       x
    (eq x. 'quote) x
    (sharp-quote-w/o-lambda? x.)
      (make-scoping-function x)
    (sharp-quote-w/o-lambda? x)
      (make-anonymous-function x)
    (@ #'make-lambdas x)))

(define-tree-filter convert-toplevel-lambdas (x)
  (named-lambda? x)
    `(CL:DEFUN ,(lambda-name x) ,(lambda-args x)
       ,@(lambda-body x))
  (%var? x)
    `(CL:DEFVAR ,(cadr x)))

(fn cl-postprocess (x)
  (make-lambdas (print (convert-toplevel-lambdas (print x)))))
