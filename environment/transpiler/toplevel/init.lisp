;;;;; TRE tree processor transpiler
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

;; Make expander for standard macro which picks macros of the same
;; name in der user-defined expander first.
(defun make-overlayed-std-macro-expander (expander-name)
  #'%%macrop
  #'%%macrocall
  (with (e (define-expander expander-name)
         mypred (expander-pred e)
		 mycall (expander-call e))
    (setf (expander-pred e) (lx (mypred)
								(fn (or (funcall ,mypred _)
				 				        (%%macrop _))))
   		  (expander-call e) (lx (mypred mycall)
								(fn (if (funcall ,mypred _)
				 				        (funcall ,mycall _)
				 				        (%%macrocall _)))))))

(defun transpiler-make-std-macro-expander (tr)
 (make-overlayed-std-macro-expander (transpiler-std-macro-expander tr)))

(defun transpiler-make-code-expander (tr)
  (define-expander (transpiler-macro-expander tr)))

(defun transpiler-make-expex (tr)
  (let ex (make-expex)
    (setf (transpiler-expex tr) ex

		  (expex-transpiler ex)
			tr

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
			         (when (atom fun)
			           (or (transpiler-function-arguments ,tr fun)
				           (and (not (transpiler-unwanted-function? ,tr fun))
					            (function? (symbol-function fun)))))))

		  (expex-function-arguments ex)
		    (lx (tr)
				#'((fun)
			         (or (transpiler-function-arguments ,tr fun)
				         (function-arguments (symbol-function fun)))))

		  (expex-plain-arg-fun? ex)
		    (lx (tr)
				#'((fun)
			         (transpiler-plain-arg-fun? ,tr fun))))
	ex))

(defun create-transpiler (&rest args)
  (let tr (apply #'make-transpiler args)
	(transpiler-reset tr)
	(transpiler-make-std-macro-expander tr)
	(transpiler-make-code-expander tr)
	(transpiler-make-expex tr)
	(transpiler-obfuscate-symbol tr nil)
	tr))
