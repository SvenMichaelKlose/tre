;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun transpiler-make-expex (tr)
  (funcall (transpiler-expex-initializer tr) (= (transpiler-expex tr) (make-expex))))

(defun create-transpiler (&rest args)
  (aprog1 (apply #'make-transpiler args)
	(transpiler-reset !)
    (= (transpiler-assert? !) *assert*)
	(transpiler-make-std-macro-expander !)
	(transpiler-make-code-expander !)
	(transpiler-make-expex !)
    (make-global-funinfo !)
    (transpiler-add-obfuscation-exceptions ! '%%native)))
