;;;;; nix operating system project ;;;;; lisp compiler
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Peephole-optimizer for expression-expanded code.

(defun find-tree (x v)
  (or (equal x v)
  	  (when (consp x)
	  	(or (find-tree (car x) v)
	        (find-tree (cdr x) v)))))

(defun opt-peephole (x)
  (with (removed-tags nil

		 ; Remove IDENTITY expressions to unify code.
		 remove-identity
		   #'((x)
				(when x
				  (with-cons a d x
					; Recurse into LAMBDA.
				    (if (and (%setq? a)
						     (is-lambda? (third a)))
					    (cons `(%setq ,(second a)
							     #'(,(lambda-args  (third a))
								     ,@(remove-identity (lambda-body (third a)))))
						      (remove-identity d))
						; Remove IDENTITY from %SETQ value.
						(if (and (%setq? a)
								 (consp (third a))
								 (identity? (third a)))
							(cons `(%setq ,(second a) ,(second (third a)))
								  (remove-identity d))
							(cons a (remove-identity d)))))))
	
		 ; Remove unreached code or code that does nothing.
		 remove-void
		   #'((x)
				(when x
				  (with-cons a d x
					; Recurse into LAMBDA.
				    (if (and (%setq? a)
						     (is-lambda? (third a)))
					    (cons `(%setq ,(second a)
							     #'(,(lambda-args  (third a))
								     ,@(remove-void (lambda-body (third a)))))
						      (remove-void d))
						; Remove void assigment.
						(if (and (%setq? a)
								 (eq (second a) (third a)))
							(remove-void d)
							; Remove second of (setf x y y x).
								(if (and (%setq? a)
										 (consp d) (%setq? (car d))
										 (eq (second a) (third (car d)))
										 (eq (second (car d)) (third a)))
									(cons a (remove-void (cdr d)))
								; Remove jump to following tag.
								(if (and (consp a)
									 	(eq 'vm-go (first a))
									 	d (atom (car d))
									 	(eq (second a) (car d)))
									(remove-void d)
									; Remove code after label until next tag.
									(if (and (consp a)
										 	(eq 'vm-go (first a)))
						    			(cons a (remove-void (find-next-tag d)))
										; Shorten (%setq expexsym sth) (%setq %ret sth).
										(if (and (%setq? a) (%setqret? (car d))
												 (expex-sym? (second a))
												 (eq (second a) (third (car d))))
											(cons `(%setq ~%ret ,(third a))
												   (remove-void (cdr d)))
											(cons a (remove-void d)))))))))))

		 will-be-set-again?
		   #'((x v)
				(or (and (atom v)
						 (expex-sym? v)
						 (not x)) ; End of block - value won't be used.
			        (when (and x (not (vm-jump? (car x)))) ; We don't know what happens after a jump.
				      (or (and (%setq? (car x))
						       (eq v (second (car x))))
					      ; Variable will be used - don't remove setter.
					      (unless (find-tree (car x) v))
					        (will-be-set-again? (cdr x) v)))))

		 find-next-tag
		   #'((x)
			    (when x
				  (if (atom (car x))
					  x
					  (find-next-tag (cdr x)))))

		 ; Remove code without side-effects whose result won't be used.
		 remove-code
		   #'((x)
				(when x
				  (with-cons a d x
					; Recurse into LAMBDA.
				    (if (and (%setq? a)
						     (is-lambda? (third a)))
					    (cons `(%setq ,(second a)
							     #'(,(lambda-args  (third a))
								     ,@(remove-code (lambda-body (third a)))))
						      (remove-code d))
						; Don't set variable that will be modified anyway.
						(if (and (%setq? a)
							 	 (or (atom (third a))
									 (get-slot? (third a))
									 (%stack? (third a)))
							 	 (will-be-set-again? d (second a)))
							(remove-code d)
        					(cons a (remove-code d)))))))

		 reduce-tags
		   #'((x)
				(when x
				  (with-cons a d x
					; Recurse into LAMBDA.
				    (if (and (%setq? a)
						     (is-lambda? (third a)))
					    (cons `(%setq ,(second a)
							     #'(,(lambda-args  (third a))
								     ,@(reduce-tags (lambda-body (third a)))))
						      (reduce-tags d))
						; Remove first of two subsequent tags.
    		            (if (and a (car d)
								 (atom a)
			 		             (atom (car d)))
	                        (progn
							  (aif (find-if #'((y)
											     (eq a (cdr y)))
											removed-tags)
								  (rplacd ! (second x)))
				          	  (acons! a (second x) removed-tags)
					          (reduce-tags d))
							(cons a (reduce-tags d)))))))
		 rec
		   #'((x)
			   (maptree #'((x)
			                (aif (assoc x removed-tags)
				                (cdr !)
					            x))
						(funcall
						  (compose #'reduce-tags
								   #'remove-code
								   #'remove-void
)
						  x))))

	(repeat-while-changes #'rec (remove-identity x))))
