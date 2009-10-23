;;;;; TRE compiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Peephole-optimizer for expression-expanded code.

(defun opt-peephole-rec (x into)
  (cons `(%setq ,(second x.) ,(copy-recurse-into-lambda (third x.) into))
        (funcall into .x)))

(defun find-all-if (pred x)
  (mapcan (fn (when (funcall pred _)
				(list _)))
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
		        (lambda? ..a.))
		   (opt-peephole-rec x ,fun)
	   	   (cond
			 ,@body
			 (t (cons a (funcall ,fun d))))))))

(defun opt-peephole-var-double? (x name)
  (with-cons a d x
    (or (and (%var? a)
             (eq name .a.))
        (opt-peephole-var-double? d name))))

(defun opt-peephole-move-vars-to-front (x)
  (with (acc nil
         rec #'((x)
                  (with-cons a d x
                    (if
					  (and (%var? a)
                           (not ..a))
                        (progn
                          (setf acc (push a acc))
                          (rec d))
                      (and (%setq? a)
                           (lambda? ..a.))
                        (cons `(%setq ,.a.
                                 ,(copy-recurse-into-lambda
                                      ..a.
                                      #'opt-peephole-move-vars-to-front))
                              (rec d))
                      (cons a
                            (rec d))))))
    (let ret (rec x)
      (append acc ret))))

(defun opt-peephole-past-vars (x)
  (if (%var? x.)
	  (opt-peephole-past-vars .x)
	  x))

(defun opt-peephole-collect-syms-0 (h x)
  (when x
    (if (atom x)
	    (setf (href h x) t)
	    (progn
		  (opt-peephole-collect-syms-0 h x.)
	      (opt-peephole-collect-syms-0 h .x)))))

(defun opt-peephole-collect-syms (x)
  (let h (make-hash-table)
	(opt-peephole-collect-syms-0 h x)
	h))

(defun opt-peephole-remove-unused-vars (x)
  (with (acc nil
		 syms (opt-peephole-collect-syms
				  (opt-peephole-past-vars x))
         rec #'((x)
                  (with-cons a d x
                    (if (and (%var? a)
                             (not ..a))
                        (progn
                          (when (if (atom .a.)
									(href syms .a.) ;(not (opt-peephole-var-double? d .a.))
									(find-tree d .a. :test #'eq))
                            (setf acc (push a acc)))
                          (rec d))
                        (if (and (%setq? a)
                                 (lambda? ..a.))
                            (cons `(%setq ,.a.
                                          ,(copy-recurse-into-lambda
                                               ..a.
                                               #'opt-peephole-remove-unused-vars))
                                  (rec d))
                            (cons a
                                  (rec d)))))))
    (let ret (rec x)
      (append acc ret))))

;; Remove IDENTITY expressions to unify code.
;; Remove IDENTITY from %SETQ value.
(defun opt-peephole-remove-identity (x)
  (opt-peephole-fun #'opt-peephole-remove-identity
      ((and (%setq? a)
		    (consp ..a.)
			(identity? ..a.))
	     (cons `(%setq ,.a. ,(second ..a.))
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
		    (equal .a. ..a.))
	     (opt-peephole-remove-void d))

      ; Remove second of (setf x y y x).
	  ((and (%setq? a)
			(%setq? d.)
			(atomic? .a.)
			(equal .a. (third d.))
			(equal (second d.) ..a.))
	     (cons a (opt-peephole-remove-void .d)))

	  ; Remove jump to following tag.
	  ((and (consp a)
			(eq 'vm-go a.)
			d
			(atom d.)
		    (eq .a. d.))
	     (opt-peephole-remove-void d))

	  ; Remove code after label until next tag.
	  ((and (consp a)
			(eq 'vm-go a.))
		 (cons a (opt-peephole-remove-void (opt-peephole-find-next-tag d))))))

(defun opt-peephole-will-be-used-again? (x v)
  (if x
      (or (vm-jump? x.) ; We don't know what happens after a jump.
		  (unless (and (%setq? x.)
			 		   (eq v (%setq-place x.)))
	        (or (find-tree x. v :test #'equal) ; Variable used?
          	    (opt-peephole-will-be-used-again? .x v))))
	  (~%ret? v)))

(defun opt-peephole (statements)
  (with
	  (removed-tags nil

	   ; Remove code without side-effects whose result won't be used.
	   remove-code
	     #'((x)
			  (opt-peephole-fun #'remove-code
				((and (%setq? a)
				   	  (not (opt-peephole-will-be-used-again? d (%setq-place a))))
				   (let p (%setq-place a)
					 (if
				       (and (atomic? (%setq-value a))
				            (or (~%ret? p)
				  		 	    (expex-sym? p)))
						 (remove-code d)
				       (or (~%ret? p)
					       (expex-sym? p))
				         (cons `(%setq ~%ret ,(%setq-value a))
					 	       (remove-code d))
					   (and d .d
							(%setq? d)
							(%setq? .d)
							(eq (%setq-place a)
								(%setq-value d))
							(atomic? ( %setq-place d))
				   	  		(not (opt-peephole-will-be-used-again? .d (%setq-place a))))
;				      		(integer= 3 (count-tree (%setq-place a) statements :max 3
;													:test #'equal)))
					     (cons `(%setq ,(%setq-place d) ,(%setq-value a))
							   (remove-code .d))
					   (cons a (remove-code d)))))))

	   reduce-tags
		 #'((x)
			  (opt-peephole-fun #'reduce-tags
    		    ((and a d.
					  (atom a)
			 		  (atom d.))
				   ; Remove first of two subsequent tags.
				   (awhen (find-if (fn eq a ._)
								   removed-tags)
					 (rplacd ! .x.))
				   (acons! a .x. removed-tags)
				   (reduce-tags d))))

	   rec
		 #'((x)
			  (maptree #'((x)
			                (aif (assoc x removed-tags :test #'eq)
				                 .!
					             x))
					   (funcall
						 (compose #'reduce-tags
								  #'remove-code
								  #'opt-peephole-remove-void)
						 x))))

		(opt-peephole-remove-unused-vars
	    	(repeat-while-changes #'rec (opt-peephole-remove-identity
	  								    	(opt-peephole-remove-spare-tags
												(opt-peephole-move-vars-to-front
												    statements)))))))
