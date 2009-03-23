;;;;; TRE compiler
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Peephole-optimizer for expression-expanded code.

(defun opt-peephole-rec (x into)
  (cons `(%setq ,(second x.) ,(copy-recurse-into-lambda (third x.) into))
        (funcall into .x)))

(defun find-all-if (pred x)
  (mapcan (fn (when (funcall pred _)
				(list _)))
		  x))

(defun find-all (elm x)
  (find-all-if (fn (eq elm _))
				x))

(defun opt-peephole-has-not-jumps-to (x tag)
  (dolist (i x t)
	(when (vm-jump? i)
	  (when (eq (vm-jump-tag i) tag)
		(return nil)))))

(defun opt-peephole-tags-lambda (x)
  (with (body x
		 spare-tags (find-all-if (fn (opt-peephole-has-not-jumps-to body _))
		  				         (find-all-if #'numberp x)))
    (remove-if (fn (member _ spare-tags))
			   x)))

(defun opt-peephole-remove-spare-tags (x)
  (when x
	(cons (if
	  		(and (%setq? x.)
	  	   		 (lambda? (third x.)))
			  (let l (third x.)
	      	    `(%setq ,(second x.)
			  	        #'(,@(lambda-funinfo-expr l)
		    		       ,(lambda-args l)
	  	       		          ,@(opt-peephole-remove-spare-tags
									(opt-peephole-tags-lambda
								        (lambda-body l))))))
			x.)
		  (opt-peephole-remove-spare-tags .x))))

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

(defun opt-peephole-var-double? (x name)
  (with-cons a d x
    (or (and (%var? a)
             (eq name (second a)))
        (opt-peephole-var-double? d name))))

(defun opt-peephole-accumulate-vars (x)
  (with (acc nil
         rec #'((x)
                  (with-cons a d x
                    (if (and (%var? a)
                             (not (cddr a)))
                        (progn
                          (when (and (not (opt-peephole-var-double? d (second a)))
                                     (find-tree d (second a)))
                            (setf acc (push a acc)))
                          (rec d))
                        (if (and (%setq? a)
                                 (lambda? (third a)))
                            (cons `(%setq ,(second a)
                                          ,(copy-recurse-into-lambda
                                               (third a)
                                               #'opt-peephole-accumulate-vars))
                                  (rec d))
                            (cons a
                                  (rec d)))))))
    (with (ret (rec x))
      (append acc ret))))

;; Remove IDENTITY expressions to unify code.
;; Remove IDENTITY from %SETQ value.
(defun opt-peephole-remove-identity (x)
  (opt-peephole-fun #'opt-peephole-remove-identity
      ((and (%setq? a)
		    (consp (third a))
			(identity? (third a)))
	     (cons `(%setq ,(second a) ,(second (third a)))
			   (opt-peephole-remove-identity d)))))

(defun opt-peephole-find-next-tag (x)
  (when x
	(if (atom x.)
		x
		(opt-peephole-find-next-tag .x))))

;; Remove unreached code or code that does nothing.
(defun opt-peephole-remove-void (x)
  (opt-peephole-fun #'opt-peephole-remove-void
	  ; Remove void assigment.
	  ((and (%setq? a)
		    (eq (second a) (third a)))
	     (opt-peephole-remove-void d))

      ; Remove second of (setf x y y x).
	  ((and (%setq? a)
	     	(consp d)
			(%setq? d.)
			(eq (second a) (third d.))
			(eq (second d.) (third a)))
	     (cons a (opt-peephole-remove-void .d)))

	  ; Remove jump to following tag.
	  ((and (consp a)
			(eq 'vm-go a.)
			d
			(atom d.)
		    (eq (second a) d.))
	     (opt-peephole-remove-void d))

	  ; Remove code after label until next tag.
	  ((and (consp a)
			(eq 'vm-go a.))
		 (cons a (opt-peephole-remove-void (opt-peephole-find-next-tag d))))

	  ; Shorten (%setq expexsym sth) (%setq sth expexsym).
	  ((and (%setq? a) (%setq? d.)
	        (expex-sym? (second a))
		    (eq (second a) (third d.)))
	     (cons `(%setq ,(second d.) ,(third a))
			   (opt-peephole-remove-void .d)))))

(defun opt-peephole (x)
  (with
	  (removed-tags nil
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
								  #'opt-peephole-remove-void)
						 x))))

	    (repeat-while-changes #'rec (opt-peephole-accumulate-vars
	  								    (opt-peephole-remove-spare-tags
									        (opt-peephole-remove-identity x))))))
