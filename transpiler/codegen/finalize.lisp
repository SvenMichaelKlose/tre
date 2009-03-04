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
		(not a)
		  ; Ignore top-level NIL.
		  (transpiler-finalize-sexprs tr .x)

	  	(atom a) 
		  ; Make jump label.
		  (cons (funcall (transpiler-make-label tr) a)
		        (transpiler-finalize-sexprs tr .x))

        (and (%setq? a)
		     (lambda? (%setq-value a)))
		  ; Recurse into function.
	      (cons `(%setq ,(%setq-place a)
				        ,(copy-recurse-into-lambda
					       (%setq-value a)
					       #'((body)
						        (transpiler-finalize-sexprs tr body))))
			    (cons separator
				      (transpiler-finalize-sexprs tr .x)))

		(eq 'function a.)
		  ; Recurse into named top-level function.
		  (cons `(function
				   ,(second a) ; name
				   (,(first (third a))
				       ,(transpiler-finalize-sexprs tr (cdr (third a)))))
				 (cons separator
				       (transpiler-finalize-sexprs tr .x)))

	    (and (identity? a)
		     (eq ret (second a)))
		  ; Ignore (IDENTITY ~%RET).
		  (transpiler-finalize-sexprs tr .x)

	    ; Just copy with separator. Make return-value assignment if missing.
		(cons (if (or (vm-jump? a)
					  (%setq? a)
					  (in? a. '%var '%transpiler-native))
				  a
				  `(%setq ,ret ,a))
			  (cons separator
				    (transpiler-finalize-sexprs tr .x)))))))
