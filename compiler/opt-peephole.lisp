;;;;; nix operating system project ;;;;; lisp compiler
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Peephole-optimizer for expression-expanded code.

(defun find-tree (x v)
  (if (atom x)
	  (eq x v)
	  (or (find-tree (car x) v)
	      (find-tree (cdr x) v))))

(defun opt-peephole (x)
  (with (removed-tags nil
		 find-next-tag
		   #'((x)
			    (when x
				  (if (atom (car x))
					  x
					  (find-next-tag (cdr x)))))

		 will-be-set-again?
		   #'((x v)
			    (when (and x
						   ; We don't know what happens after a jump.
						   (not (vm-jump? (car x))))
				  (or (and (%setq? (car x))
						   (eq v (second (car x))))
					  ; Variable will be used - don't remove setter.
					  (unless (find-tree (car x) v))
					    (will-be-set-again? (cdr x) v))))

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
						; Remove void assigment.
						(if (and (%setq? a)
								 (consp (third a))
								 (eq 'identity (first (third a)))
								 (eq (second a) (second (third a))))
							(remove-code d)
							; Remove jump to following tag.
							(if (and (consp a)
									 (eq 'vm-go (first a))
									 d (atom (car d))
									 (eq (second a) (car d)))
								(remove-code d)
								; Remove code after label until next tag.
								(if (and (consp a)
										 (eq 'vm-go (first a)))
						    		(cons a (remove-code (find-next-tag d)))
									; Remove second of (setf x y y x).
									(if (and (%setq? a)
											 (consp d) (%setq? (car d))
											 (eq (second a) (third (car d)))
											 (eq (second (car d)) (third a)))
										(cons a (remove-code (cdr d)))
										; Don't set variable that will be modified anyway.
										(if (and (%setq? a)
											 	 (or (atom (third a))
													 (%stack? (third a)))
											 	 (will-be-set-again? d (second a)))
											(remove-code d)
				        					(cons a (remove-code d)))))))))))


		 find-double-tags
		   #'((x)
				(when x
				  (with-cons a d x
					; Recurse into LAMBDA.
				    (if (and (%setq? a)
						     (is-lambda? (third a)))
					    (cons `(%setq ,(second a)
							     #'(,(lambda-args  (third a))
								     ,@(find-double-tags (lambda-body (third a)))))
						      (find-double-tags d))
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
					          (find-double-tags d))
							(cons a (find-double-tags d)))))))
		 rec
		   #'((x)
			   (maptree #'((x)
			                (aif (assoc x removed-tags)
				                (cdr !)
					            x))
			            (find-double-tags (remove-code x)))))
	(repeat-while-changes #'rec x)))
