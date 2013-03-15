;;;;; tré – Copyright (c) 2008,2012–2013 Sven Michael Klose <pixel@copei.de>

(defun transpiler-make-named-functions (tr x)
  (?
    (not x) x
    (& (%setq? x.)
        (alet (%setq-value x.)
         (| (lambda? !)
            (named-lambda? !))))
        (alet (%setq-value x.)
          (cons (copy-lambda ! :name (? (named-lambda? !)
                                        (lambda-name !)
                                        (%setq-place x.)))
                (transpiler-make-named-functions tr (funcall (transpiler-named-function-next tr) x))))
    (%%block? x.)
      (cons (transpiler-make-named-functions tr x.)
            (transpiler-make-named-functions tr .x))
    (cons x. (transpiler-make-named-functions tr .x))))
