;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun transpiler-make-expex (tr)
  (let ex (make-expex)
    (= (transpiler-expex tr) ex
	   (expex-transpiler ex) tr)
	ex))

(defun create-transpiler (&rest args)
  (aprog1 (apply #'make-transpiler args)
	(transpiler-reset !)
    (= (transpiler-assert? !) *assert*)
	(transpiler-make-std-macro-expander !)
	(transpiler-make-code-expander !)
	(funcall (transpiler-expex-initializer !) (transpiler-make-expex !))
    (make-global-funinfo !)))
