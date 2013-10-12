;;;;; tré – Copyright (c) 2008,2012–2013 Sven Michael Klose <pixel@copei.de>

(defun correct-functions (x)
  (?
    (not x) x
    (named-lambda? x.)
        (alet x.
          (. (copy-lambda ! :body (correct-functions (lambda-body !)))
             (correct-functions .x)))
    (& (%setq? x.)
       (named-lambda? (%setq-value x.)))
        (alet (%setq-value x.)
          `(,(copy-lambda ! :body (correct-functions (lambda-body !)))
            ,@(& (not (transpiler-lambda-export? *transpiler*))
                 `((%setq ,(%setq-place x.) ,(lambda-name !))))
            ,@(correct-functions .x)))
    (%%block? x.)
      (cons-r correct-functions x)
    (. x. (correct-functions .x))))
