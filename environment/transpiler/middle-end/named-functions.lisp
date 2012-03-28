;;;;; tré - Copyright (c) 2008,2012 Sven Michael Klose <pixel@copei.de>

(defun transpiler-make-named-functions-0 (tr x)
  (when x
    (? (and (%setq? x.)
            (lambda? (caddr x.)))
       (cons `(function ,(cadadr x) ,(cadaddr x.))
             (transpiler-make-named-functions-0 tr (funcall (transpiler-named-function-next tr) x)))
       (cons (? (%%vm-scope? x.)
	            (transpiler-make-named-functions-0 tr x.)
                x.)
		     (transpiler-make-named-functions-0 tr .x)))))

(defun transpiler-make-named-functions (tr x)
  (? (transpiler-named-functions? tr)
     (transpiler-make-named-functions-0 tr x)
     x))
