;;;;; TRE to C transpiler
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>

(defun transpiler-make-named-functions-0 (tr x)
  (when x
    (if (and (%setq? x.)
             (lambda? (third x.)))
        (cons `(function ,(second (second x)) ,(second (third x.)))
              (transpiler-make-named-functions-0 tr (funcall (transpiler-named-function-next tr) x)))
        (cons (if (%%vm-scope? x.)
	              (transpiler-make-named-functions-0 tr x.)
                  x.)
			  (transpiler-make-named-functions-0 tr .x)))))

(defun transpiler-make-named-functions (tr x)
  (if (transpiler-named-functions? tr)
	  (transpiler-make-named-functions-0 tr x)
	  x))
