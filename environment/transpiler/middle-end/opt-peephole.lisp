;;;;; TRE compiler
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Peephole-optimizer for expression-expanded code.

(defvar *opt-peephole-funinfo* nil)
(defvar *opt-peephole-symbols* (make-hash-table))

(metacode-walker opt-peephole-collect-syms-0 (x h)
	:traverse?	t
    :if-symbol	(setf (href h x) (1+ (or (href h x)
								 		 0)))
	:if-atom	nil
	:if-function (opt-peephole-collect-syms-0 (%setq-place x) h))

(defun opt-peephole-collect-syms (x)
  (let h (make-hash-table)
	(opt-peephole-collect-syms-0 x h)
	h))

(metacode-walker opt-peephole-uncollect-syms-0 (x)
	:traverse?	t
    :if-symbol	(setf (href *opt-peephole-symbols* x)
					  (1- (or (href *opt-peephole-symbols* x)
							  0)))
	:if-atom	nil
	:if-function (opt-peephole-uncollect-syms-0 (%setq-place x)))

(defun opt-peephole-uncollect-syms (x ret)
  (opt-peephole-uncollect-syms-0 x)
  ret)

(defun opt-peephole-count (x)
  (or (href *opt-peephole-symbols* x)
	  0))

(defun opt-peephole-rec (a d val fun name collect-symbols)
  (with (plc (%setq-place a)
		 body (lambda-body val))
	(with-temporary *opt-peephole-funinfo* (get-lambda-funinfo val)
	  (with-temporary *opt-peephole-symbols* (if collect-symbols
										      (opt-peephole-collect-syms body)
											  *opt-peephole-symbols*)
	    (cons `(%setq ,plc
		              (function ,@(awhen name
								    (list !))
					            (,@(lambda-head val)
					             ,@(funcall fun body))))
		      (funcall fun d))))))

(defmacro opt-peephole-fun ((fun &key (collect-symbols nil)) &rest body)
  `(when x
	 (with-cons a d x
	   ; Recurse into LAMBDA.
	   (if
		 (and (%setq? a)
			  (named-function-expr? (%setq-value a)))
		   (opt-peephole-rec a d (third (%setq-value a)) ,fun
							 (second (%setq-value a)) ,collect-symbols)

		 (and (%setq? a)
			  (lambda? (%setq-value a)))
		   (opt-peephole-rec a d (%setq-value a) ,fun
							 nil ,collect-symbols)

	   	 (cond
		   ,@body
		   (t (cons a (funcall ,fun d))))))))

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

;; Remove IDENTITY expressions to unify code.
;; Remove IDENTITY from %SETQ value.
(defun opt-peephole-remove-identity (x)
  (opt-peephole-fun (#'opt-peephole-remove-identity)
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
  (opt-peephole-fun (#'opt-peephole-remove-void)
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

(defun opt-peephole-will-be-used-again? (x v)
  (if
	(not (funinfo-parent *opt-peephole-funinfo*))	t
	(not x)			(~%ret? v)	; End of block always returns ~%RET.
	(atom x)		(error "illegal meta-code: statement expected")
	(lambda? x.)	(opt-peephole-will-be-used-again? .x v) ; Skip LAMBDA-expressions.

    (or (vm-jump? x.)				; We don't know what happens after a jump.
	    (if (and (%setq? x.)
		 		 (eq v (%setq-place x.)))
			(find-tree (%setq-value x.) v :test #'eq)
            (or (find-tree x. v :test #'eq) ; Place used in statement?
   	            (opt-peephole-will-be-used-again? .x v))))))

(defun removable-place? (v)
  (let fi *opt-peephole-funinfo*
    (when (and v (atom v))
	  (or (~%ret? v)
	      (not (or (eq v (funinfo-lexical fi))
	    	       (not (funinfo-in-env? fi v))
	    	       (funinfo-lexical? fi v)))))))

(defun opt-peephole (statements)
  (with
	  (fnord nil
	   removed-tags nil

	   ; Remove code without side-effects whose result won't be used.
	   remove-code
	     #'((x)
			  (opt-peephole-fun (#'remove-code :collect-symbols t)
				((and (%setq? a)
				      (removable-place? (%setq-place a))
					  (or (and (not (~%ret? (%setq-place a)))
							   (integer= 1 (opt-peephole-count (%setq-place a))))
					      (not (opt-peephole-will-be-used-again? d (%setq-place a)))))
				   (if (atom (%setq-value a))
			  		   (opt-peephole-uncollect-syms a
						   (remove-code d))
			  		   (opt-peephole-uncollect-syms (%setq-place a)
						   (cons `(%setq nil ,(%setq-value a))
							     (remove-code d)))))))

	   remove-assignments
	     #'((x)
			  (opt-peephole-fun (#'remove-assignments :collect-symbols t)
			    ((and d
					  (%setq? a)
					  (%setq? d.)
					  (let plc (%setq-place a)
						(and (eq plc (%setq-value d.))
 							 (removable-place? plc)
							 (or (not (opt-peephole-will-be-used-again? .d plc))
								 (and (integer= 2 (opt-peephole-count plc))
								 	  (not (~%ret? plc)))))))
				  (let plc (%setq-place a)
				    (opt-peephole-uncollect-syms plc
						  (opt-peephole-uncollect-syms plc
							  (cons `(%setq ,(%setq-place d.) ,(%setq-value a))
								    (remove-assignments .d))))))))

	   reduce-tags
		 #'((x)
			  (opt-peephole-fun (#'reduce-tags)
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
	(with-temporary *opt-peephole-funinfo* *global-funinfo*
	  (repeat-while-changes #'rec
		(opt-peephole-remove-identity statements)))))
