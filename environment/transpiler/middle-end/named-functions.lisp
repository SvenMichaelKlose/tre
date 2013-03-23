;;;;; tré – Copyright (c) 2008,2012–2013 Sven Michael Klose <pixel@copei.de>

(defun transpiler-make-named-functions (tr x)
  (?
    (not x) x
    (named-lambda? x.)
        (alet x.
          (cons (copy-lambda ! :body (transpiler-make-named-functions tr (lambda-body !)))
                (transpiler-make-named-functions tr .x)))
    (& (%setq? x.)
        (alet (%setq-value x.)
          (| (lambda? !)
             (named-lambda? !))))
        (alet (%setq-value x.)
          `(,(copy-lambda ! :name (? (named-lambda? !)
                                     (lambda-name !)
                                     (%setq-place x.))
                            :body (transpiler-make-named-functions tr (lambda-body !)))
            ,@(& (not (transpiler-lambda-export? tr))
                 (named-lambda? !)
                 `((%setq ,(%setq-place x.) ,(lambda-name !))))
            ,@(transpiler-make-named-functions tr (funcall (transpiler-named-function-next tr) x))))
    (%%block? x.)
      (cons (transpiler-make-named-functions tr x.)
            (transpiler-make-named-functions tr .x))
    (cons x. (transpiler-make-named-functions tr .x))))
