;;;;; nix operating system project ;;;;; lisp compiler
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Peephole-optimizer for expression-expanded code.

(defun opt-peephole-rec (x into)
  (cons `(%setq ,(second (car x)) ,(copy-recurse-into-lambda (third (car x)) into))
        (funcall into (cdr x))))

(defmacro opt-peephole-fun (fun &rest body)
  `(when x
	 (with-cons a d x
	   ; Recurse into LAMBDA.
	   (if (and (%setq? a)
		        (is-lambda? (third a)))
		   (opt-peephole-rec x ,fun)
	   	   (cond
			 ,@body
			 (t	(cons a (funcall ,fun d))))))))

(defun opt-peephole (x)
  (with
	  (removed-tags nil

	  ; Remove IDENTITY expressions to unify code.
	  remove-identity
	    #'((x)
		     (opt-peephole-fun #'remove-identity
			   ((and (%setq? a)
				     (consp (third a))
					 (identity? (third a)))
			 	     ; Remove IDENTITY from %SETQ value.
					 (cons `(%setq ,(second a) ,(second (third a)))
						   (remove-identity d)))))
	
		 ; Remove unreached code or code that does nothing.
		 remove-void
		   #'((x)
			    (opt-peephole-fun #'remove-void
				  ((and (%setq? a)
						(eq (second a) (third a)))
				  		; Remove void assigment.
						(remove-void d))

				  ((and (%setq? a)
						(consp d) (%setq? (car d))
						(eq (second a) (third (car d)))
						(eq (second (car d)) (third a)))
				    	; Remove second of (setf x y y x).
						(cons a (remove-void (cdr d))))

				  ((and (consp a)
						(eq 'vm-go (first a))
						d (atom (car d))
						(eq (second a) (car d)))
						; Remove jump to following tag.
						(remove-void d))

				  ((and (consp a)
						(eq 'vm-go (first a)))
						; Remove code after label until next tag.
					    (cons a (remove-void (find-next-tag d))))

				  ((and (%setq? a) (%setq? (car d))
						(expex-sym? (second a))
						(eq (second a) (third (car d))))
						; Shorten (%setq expexsym sth) (%setq sth expexsym).
						(cons `(%setq ,(second (car d)) ,(third a))
							  (remove-void (cdr d))))))

		 will-be-set-again?
		   #'((x v)
				(unless (and (atom v)
						     (expex-sym? v)
						     (not x)) ; End of block - value won't be used.
			        (or (and x
						     (not (vm-jump? (car x)))) ; We don't know what happens after a jump.
				        (unless (and (%setq? (car x))
						             (eq v (second (car x))))
					        ; Variable will be used - don't remove setter.
					        (or (find-tree (car x) v)
					            (will-be-set-again? (cdr x) v))))))

		 find-next-tag
		   #'((x)
			    (when x
				  (if (atom (car x))
					  x
					  (find-next-tag (cdr x)))))

		 ; Remove code without side-effects whose result won't be used.
		 remove-code
		   #'((x)
				(opt-peephole-fun #'remove-code
				  ((and (%setq? a)
					    (second a)
					    (or (atom (third a))
						    (%stack? (third a)))
						    (will-be-set-again? d (second a)))
				  		; Don't set variable that will be modified anyway.
					  	(remove-code d))))

		 reduce-tags
		   #'((x)
				(opt-peephole-fun #'reduce-tags
    		      ((and a (car d)
						(atom a)
			 		    (atom (car d)))
				    	; Remove first of two subsequent tags.
						(awhen (find-if #'((y)
										     (eq a (cdr y)))
									    removed-tags)
							   (rplacd ! (second x)))
				        (acons! a (second x) removed-tags)
					    (reduce-tags d))))

		 rec
		   #'((x)
			   (maptree #'((x)
			                 (aif (assoc x removed-tags)
				                  (cdr !)
					              x))
						(funcall
						  (compose #'reduce-tags
								   ;#'remove-code
								   #'remove-void
)
						  x))))

	(repeat-while-changes #'rec (remove-identity x))))
