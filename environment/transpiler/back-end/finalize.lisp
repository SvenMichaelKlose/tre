;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

;;;; EXPRESSION FINALIZATION

(defvar *codegen-num-instructions* 0)

;; Make jump labels.
;; Remove (IDENTITY ~%RET)  expressions.
;; Add %VAR declarations for expex symbols.
(defun transpiler-finalize-sexprs (tr x &optional (toplevel t))
  (when x
	(with (a          x.
		   ret		  (transpiler-obfuscate tr '~%ret))
	  (if
		; Ignore top-level NIL.
		(not a)
		  (transpiler-finalize-sexprs tr .x)

		; Make jump label.
	  	(atom a) 
		  (cons (funcall (transpiler-make-label tr) a)
		        (transpiler-finalize-sexprs tr .x))

		; Recurse into function.
        (and (%setq? a)
		     (lambda? (%setq-value a)))
	      (cons `(%setq ,(%setq-place a)
				        ,(copy-recurse-into-lambda
					       (%setq-value a)
					       #'((body)
						        (transpiler-finalize-sexprs tr body))))
				(transpiler-finalize-sexprs tr .x))

		; Recurse into named top-level function.
		(and toplevel
			 (eq 'function a.))
		  (cons `(function
				   ,(second a) ; name
				   (,@(lambda-head (third a))
				       ,(transpiler-finalize-sexprs tr
						    (lambda-body (third a))
							nil)))
				 (transpiler-finalize-sexprs tr .x))

		; Ignore (IDENTITY ~%RET).
	    (and (identity? a)
		     (eq ret (second a)))
		  (transpiler-finalize-sexprs tr .x)

	    (progn
		  (1+! *codegen-num-instructions*)
		  (cons a
			    (transpiler-finalize-sexprs tr .x)))))))
