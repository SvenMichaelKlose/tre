;;;;; TRE compiler
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Peephole-optimizer for expression-expanded code.

(defun opt-peephole-rec (x into)
  (cons `(%setq ,(second x.) ,(copy-recurse-into-lambda (third x.) into))
        (funcall into .x)))

(defmacro opt-peephole-fun (fun &rest body)
  `(when x
	 (with-cons a d x
	   ; Recurse into LAMBDA.
	   (if (and (%setq? a)
		        (lambda? (third a)))
		   (opt-peephole-rec x ,fun)
	   	   (cond
			 ,@body
			 (t	(cons a (funcall ,fun d))))))))

(defun opt-peephole (x)
  (with
	  (removed-tags nil

	   var-double?
		 #'((x name)
			  (when x
                (with-cons a d x
				  (or (and (%var? a)
						   (eq name (second a)))
					  (var-double? d name)))))

	   accumulate-vars
		 #'((x)
			  (with (acc nil
					 rec #'((x)
			                  (when x
				                (with-cons a d x
				                  (if (and (%var? a)
										   (not (cddr a)))
					                  (progn
										(when (and (not (var-double? d (second a)))
												   (find-tree d (second a)))
										  (setf acc (push a acc)))
						                (rec d))
				  	                  (if (and (%setq? a)
					       	                   (lambda? (third a)))
						                  (cons `(%setq ,(second a)
												        ,(copy-recurse-into-lambda (third a) #'accumulate-vars))
												(rec d))
						                  (cons a
								                (rec d))))))))
				(with (ret (rec x))
				  (append acc ret))))

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

	   find-next-tag
		 #'((x)
			  (when x
				(if (atom x.)
					x
					(find-next-tag .x))))

	   ; Remove unreached code or code that does nothing.
	   remove-void
		 #'((x)
			  (opt-peephole-fun #'remove-void
				((and (%setq? a)
					  (eq (second a) (third a)))
				   ; Remove void assigment.
				   (remove-void d))

				((and (%setq? a)
				      (consp d) (%setq? d.)
					  (eq (second a) (third d.))
					  (eq (second d.) (third a)))
				   ; Remove second of (setf x y y x).
				   (cons a (remove-void .d)))

				((and (consp a)
					  (eq 'vm-go a.)
					  d (atom d.)
					  (eq (second a) d.))
				   ; Remove jump to following tag.
				   (remove-void d))

				((and (consp a)
					  (eq 'vm-go a.))
				   ; Remove code after label until next tag.
				   (cons a (remove-void (find-next-tag d))))

				((and (%setq? a) (%setq? d.)
				      (expex-sym? (second a))
					  (eq (second a) (third d.)))
				   ; Shorten (%setq expexsym sth) (%setq sth expexsym).
				   (cons `(%setq ,(second d.) ,(third a))
						 (remove-void .d)))))

	   will-be-set-again?
		 #'((x v)
			  (if x
			      (or (and (%setq? x.)
					       (eq v (second x.)))
		              (unless (or (vm-jump? x.) ; We don't know what happens after a jump.
				                  (find-tree x. v)) ; Variable will be used.
				        (will-be-set-again? .x v)))
				  (and (atom v) ; End of block, EXPEX-sym not used.
					   (expex-sym? v))))

	   ; Remove code without side-effects whose result won't be used.
	   remove-code
	     #'((x)
			  (opt-peephole-fun #'remove-code
				((and (%setq? a)
					  (atom (second a))
					  (or (atom (third a))
						  (%slot-value? (third a))
						  (%stack? (third a)))
					  (will-be-set-again? d (second a)))
				  	  ; Don't set variable that will be modified anyway.
					  (remove-code d))))

	   reduce-tags
		 #'((x)
			  (opt-peephole-fun #'reduce-tags
    		    ((and a d.
					  (atom a)
			 		  (atom d.))
				   ; Remove first of two subsequent tags.
				   (awhen (find-if (fn eq a (cdr _))
								   removed-tags)
					 (rplacd ! (second x)))
				   (acons! a (second x) removed-tags)
				   (reduce-tags d))))

	   rec
		 #'((x)
			  (maptree #'((x)
			                (aif (assoc x removed-tags)
				                 .!
					             x))
					   (funcall
						 (compose #'reduce-tags
								  #'remove-code
								  #'remove-void)
						 x))))

	(accumulate-vars
	  (repeat-while-changes #'rec (accumulate-vars
									(remove-identity x))))))
