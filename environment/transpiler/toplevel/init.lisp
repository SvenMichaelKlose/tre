;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(defun transpiler-make-expex (tr)
  (let ex (make-expex)
    (= (transpiler-expex tr) ex

	   (expex-transpiler ex) tr

	   (expex-function-collector ex)
	       (lx (tr)
		     #'((fun args)
		          (transpiler-add-wanted-function ,tr fun)))

	   (expex-argument-filter ex)
	       (lx (tr)
	    	 #'((var)
		          (transpiler-add-wanted-variable ,tr var)))

	   (expex-functionp ex)
	       (lx (tr)
			 #'((fun)
		          (& (atom fun)
		             (| (transpiler-function-arguments ,tr fun)
			            (& (not (transpiler-unwanted-function? ,tr fun))
				           (function? (symbol-function fun)))))))

	   (expex-function-arguments ex)
	       (lx (tr)
			 #'((fun)
		          (| (transpiler-function-arguments ,tr fun)
			         (transpiler-host-function-arguments ,tr fun))))

	   (expex-plain-arg-fun? ex)
	       (lx (tr)
			 #'((fun)
		          (transpiler-plain-arg-fun? ,tr fun))))
	ex))

(defun create-transpiler (&rest args)
  (aprog1 (apply #'make-transpiler args)
	(transpiler-reset !)
	(transpiler-make-std-macro-expander !)
	(transpiler-make-code-expander !)
	(funcall (transpiler-expex-initializer !) (transpiler-make-expex !))
    (make-global-funinfo !)))
