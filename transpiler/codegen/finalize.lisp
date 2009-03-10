;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

;;;; EXPRESSION FINALIZATION

;; Add separators.
;;   Separators cannot be added later, because the expression bounds will
;;   disappear when everything is expanded to target-language strings in
;;   the next pass.
;; Make jump labels.
;; Remove (IDENTITY ~%RET)  expressions.
;; Add %VAR declarations for expex symbols.
(defun transpiler-finalize-sexprs (tr x)
  (when x
	(with (a          x.
		   separator  (transpiler-separator tr)
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
			    (cons separator
				      (transpiler-finalize-sexprs tr .x)))

		; Recurse into named top-level function.
		(eq 'function a.)
		  (cons `(function
				   ,(second a) ; name
				   (,(lambda-args (third a))
				       ,(transpiler-finalize-sexprs tr
						    (lambda-body (third a)))))
				 (cons separator
				       (transpiler-finalize-sexprs tr .x)))

		; Ignore (IDENTITY ~%RET).
	    (and (identity? a)
		     (eq ret (second a)))
		  (transpiler-finalize-sexprs tr .x)

	    ; Just copy with separator. Make return-value assignment if missing.
		(cons (if (or (vm-jump? a)
					  (%setq? a)
					  (in? a. '%var '%transpiler-native))
				  a
				  `(%setq ,ret ,a))
			  (cons separator
				    (transpiler-finalize-sexprs tr .x)))))))
