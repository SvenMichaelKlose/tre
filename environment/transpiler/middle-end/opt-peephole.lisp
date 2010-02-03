;;;;; TRE compiler
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Peephole-optimizer for expression-expanded code.

(defvar *opt-peephole-funinfo* nil)

(defun opt-peephole-rec (x into)
  (with (old-funinfo *opt-peephole-funinfo*
		 *opt-peephole-funinfo* (get-lambda-funinfo (third x.)))
	(prog1
      (cons `(%setq ,(second x.) ,(copy-recurse-into-lambda (third x.) into))
            (funcall into .x))
	  (setf *opt-peephole-funinfo* old-funinfo))))

(defun find-all-if (pred x)
  (mapcan (fn (when (funcall pred _)
				(list _)))
		  x))

(defun opt-peephole-has-no-jumps-to (x tag)
  (dolist (i x t)
	(when (vm-jump? i)
	  (when (= (vm-jump-tag i) tag)
		(return nil)))))

(defun opt-peephole-tags-lambda (x)
  (with (body x
		 spare-tags (find-all-if (fn opt-peephole-has-no-jumps-to body _)
		  				         (find-all-if #'numberp x)))
    (remove-if (fn member _ spare-tags)
			   x)))

(defun opt-peephole-remove-spare-tags (x)
  (when x
	(cons (if
	  		(and (%setq? x.)
	  	   		 (lambda? (third x.)))
			  (let l (third x.)
	      	    `(%setq ,(second x.)
			  	        #'(,@(lambda-head l)
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
		    (eq .a. ..a.))
	     (opt-peephole-remove-void d))

      ; Remove second of (setf x y y x).
	  ((and (%setq? a)
			(%setq? d.)
			(atomic? .a.)
			(eq .a. (third d.))
			(eq (second d.) ..a.))
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

(defun opt-peephole-will-be-used-again-0? (x v &key (ignore-lambda? nil))
  (if x
	  (if (and ignore-lambda?
			   (lambda? x.))
  	      (opt-peephole-will-be-used-again-0? .x v :ignore-lambda? ignore-lambda?)
          (or (vm-jump? x.) ; We don't know what happens after a jump.
		      (unless (and (%setq? x.)
			 		  (eq v (%setq-place x.)))
	            (or (find-tree x. v :test #'eq) ; Variable used?
          	        (opt-peephole-will-be-used-again-0? .x v :ignore-lambda? ignore-lambda?)))))
	  (~%ret? v)))

(defun opt-peephole-will-be-used-again? (x v)
  (aif *opt-peephole-funinfo*
	   (or (not (funinfo-in-this-or-parent-env? ! v)) ; Don't optimize globals away.
		   (funinfo-in-parent-env? ! v)
	  	   (funinfo-lexical-pos ! v)
	  	   (opt-peephole-will-be-used-again-0? x v :ignore-lambda? t))
	   (opt-peephole-will-be-used-again-0? x v :ignore-lambda? nil)))

(defun opt-peephole (statements)
  (with
	  (removed-tags nil

	   ; Remove code without side-effects whose result won't be used.
	   remove-code
	     #'((x)
			  (opt-peephole-fun #'remove-code
				((and (%setq? a)
				      (atom (%setq-value a))
				   	  (not (opt-peephole-will-be-used-again? d (%setq-place a))))
				   (let p (%setq-place a)
					 (if (or (~%ret? p)
				  		     (expex-sym? p))
						 (remove-code d)
					   (cons a (remove-code d)))))))

	   remove-assignments
	     #'((x)
			  (opt-peephole-fun #'remove-assignments
			    ((and d
					  (%setq? a)
					  (%setq? d.)
					  (expex-sym? (%setq-place a))
					  (eq (%setq-place a)
						  (%setq-value d.)))
				   	  ;(not (opt-peephole-will-be-used-again? .d (%setq-place a))))
				  (cons `(%setq ,(%setq-place d.) ,(%setq-value a))
					    (remove-assignments .d)))))

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
								  #'opt-peephole-remove-spare-tags
								  #'remove-code
								  #'remove-assignments
								  #'opt-peephole-remove-void)
						 x))))

		(opt-peephole-remove-unused-vars
	    	(repeat-while-changes #'rec (opt-peephole-remove-identity
											(opt-peephole-move-vars-to-front
											    statements))))))
