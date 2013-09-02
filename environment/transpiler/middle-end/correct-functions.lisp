;;;;; tré – Copyright (c) 2008,2012–2013 Sven Michael Klose <pixel@copei.de>

(defun correct-functions (tr x)
  (?
    (not x) x
    (named-lambda? x.)
        (alet x.
          (cons (copy-lambda ! :body (correct-functions tr (lambda-body !)))
                (correct-functions tr .x)))
    (& (%setq? x.)
       (named-lambda? (%setq-value x.)))
        (alet (%setq-value x.)
          `(,(copy-lambda ! :body (correct-functions tr (lambda-body !)))
            ,@(& (not (transpiler-lambda-export? tr))
                 `((%setq ,(%setq-place x.) ,(lambda-name !))))
            ,@(correct-functions tr .x)))
    (%%block? x.)
      (cons (correct-functions tr x.)
            (correct-functions tr .x))
    (cons x. (correct-functions tr .x))))
