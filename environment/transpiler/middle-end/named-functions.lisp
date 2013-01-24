;;;;; tré – Copyright (c) 2008,2012–2013 Sven Michael Klose <pixel@copei.de>

(defun transpiler-make-named-functions (tr x)
  (?
    (not x) x
    (& (transpiler-named-functions? tr)
       (%setq? x.)
       (lambda? (caddr x.)))
      (cons `(function ,(cadadr x) ,(cadaddr x.))
            (transpiler-make-named-functions tr (funcall (transpiler-named-function-next tr) x)))
    (%%block? x.)
      (cons (transpiler-make-named-functions tr x.)
            (transpiler-make-named-functions tr .x))
    nil ;(transpiler-accumulate-toplevel-expressions? tr)
      (progn
        (transpiler-add-toplevel-expression tr x.)
        (transpiler-make-named-functions tr .x))
    (cons x. (transpiler-make-named-functions tr .x))))
