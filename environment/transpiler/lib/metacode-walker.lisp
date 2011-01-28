;;;;; TRE compiler
;;;;; Copyright (c) 2010-2011 Sven Klose <pixel@copei.de>

(defun function-copier-0 (x body-statements)
  `(function ,,@(awhen (lambda-name ,x) (list !))
     (,,@(lambda-head ,x)
      ,(list 'quasiquote-splice body-statements))))

(defun function-copier (x body-statements)
  (list 'backquote (function-copier-0 x body-statements)))

(defun %setq-function-copier (x body-statements)
  (list 'backquote `(%setq ,,(%setq-place ,x)
						   ,(function-copier-0 `(%setq-value ,x)
							  				   `(let ,x (%setq-value ,x)
								     			  ,body-statements)))))

(defun metacode-walker-copier (x statement &key (%setq? nil) (copy? nil))
  (if copy?
      (let s statement
	    (if %setq?
	        (%setq-function-copier x s)
	        (function-copier x s)))
	  statement))

(defmacro metacode-walker-statements (name args &key (if-atom nil)
										  			 (if-cons nil)
										  			 (if-slot-value nil)
										  			 (if-function nil)
										  			 (if-lambda nil)
										  			 (if-named-function nil)
										      		 (copy-function-heads? nil)
													 (only-statements? t))
  (with-cons x r args
    `(defun ,name ,args
	   (with (rec
				#'((x)
                     (if
					   (and (%setq? ,x)
							(cons? (%setq-value ,x))
							(eq '%%tag (car (%setq-value ,x))))
					     (progn
						   (print ,x)
						   (error "illegal tag, not in toplevel"))
		               (not ,x)		nil
		               ,@(awhen if-atom `((atom ,x)	,!))
		               ,@(awhen if-slot-value `((%slot-value? ,x) ,!))

		               ,@(awhen (or if-named-function if-function)
			               `((%setq-named-function? ,x)
			    			   ,(metacode-walker-copier x ! :%setq? t :copy? copy-function-heads?)
			                 (named-lambda? ,x)
			    			   ,(metacode-walker-copier x ! :copy? copy-function-heads?)))

		               ,@(awhen (or if-lambda if-function)
			               `((%setq-lambda? ,x)
			    			   ,(metacode-walker-copier x ! :%setq? t :copy? copy-function-heads?)))

		               ,@(awhen if-cons `((cons? ,x) ,!))

		               (not (or (in? (car ,x) '%setq '%var '%function-prologue '%function-epilogue '%function-return '%%tag)
								(vm-jump? ,x)
                                (%%vm-call-nil? ,x)))
		                 (progn
			               (print ,x)
			               (error "metacode statement expected instead"))

					   (copy-tree x))))
		(mapcar #'rec ,x)))))

(defmacro metacode-walker-all (name args &key (if-atom nil)
					  	    		          (if-symbol nil)
										      (if-function nil)
										      (if-lambda nil)
										      (if-named-function nil)
										      (if-slot-value nil)
										      (if-stack nil)
										      (if-vec nil)
										      (traverse? nil)
										      (copy-function-heads? nil)
										      (only-statements? nil))
  (with-cons x r args
    `(defun ,name ,args
       (if
		 (atom ,x)
	       (if (not ,x) nil
	           ,@(awhen if-symbol	`((symbol? ,x) ,!))
	           ,@(awhen if-atom		`((atom ,x) ,!))
			   ,@(unless traverse?
				   (list x)))
		,@(awhen if-slot-value	`((%slot-value? ,x)	,!))
		,@(awhen if-stack		`((%stack? ,x)		,!))
		,@(awhen if-vec			`((%vec? ,x)		,!))

		(in? (car ,x) '%quote '%var '%transpiler-native)
		   ,(if traverse?
			     nil
			     x)

		,@(awhen (or if-named-function if-function)
			`((named-lambda? ,x)
			    ,(metacode-walker-copier x ! :copy? copy-function-heads?)))

		,@(awhen (or if-lambda if-function)
			`((lambda? ,x)
			    ,(metacode-walker-copier x ! :copy? copy-function-heads?)))

	    (,(if traverse?
			  'progn
			  'cons)
	        (,name (car ,x) ,@r)
	        (,name (cdr ,x) ,@r))))))

(defmacro metacode-walker (name args &rest config)
  (let p (position :only-statements? config)
	(if (and p (elt config (1+ p)))
	    `(metacode-walker-statements ,name ,args ,@config)
	    `(metacode-walker-all ,name ,args ,@config))))
