;;;;; TRE compiler
;;;;; Copyright (c) 2010 Sven Klose <pixel@copei.de>

(defun function-copier-0 (x body-statements)
  `(function ,,@(awhen (function-name ,x) (list !))
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
		               (not ,x)		nil
		               ,@(awhen if-atom `((atom ,x)	,!))

		               ,@(awhen (or if-named-function if-function)
			               `((%setq-named-function? ,x)
			    			   ,(metacode-walker-copier x ! :%setq? t :copy? copy-function-heads?)
			                 (named-function-expr? ,x)
			    			   ,(metacode-walker-copier x ! :copy? copy-function-heads?)))

		               ,@(awhen (or if-lambda if-function)
			               `((%setq-lambda? ,x)
			    			   ,(metacode-walker-copier x ! :%setq? t :copy? copy-function-heads?)))

		               (not (or (in? (car ,x) '%setq '%var '%function-prologue '%function-epilogue '%function-return)
								(vm-jump? ,x)))
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
	           ,@(awhen if-symbol	`((symbolp ,x) ,!))
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
			`((named-function-expr? ,x)
			    ,(metacode-walker-copier x ! :copy? copy-function-heads?)))

		,@(awhen (or if-lambda if-function)
			`((lambda? ,x)
			    ,(metacode-walker-copier x ! :copy? copy-function-heads?)))

	    (,(if traverse?
			  'progn
			  'cons)
	        (,name (car ,x) ,@r)
	        (,name (cdr ,x) ,@r))))))

;; Replace macro by more specific macro with differing argument definition.
;; Leaves argument checking to environment.
(defmacro metacode-walker (name args &rest config)
  (let p (position :only-statements? config)
	(if (and p (elt config (1+ p)))
	    `(metacode-walker-statements ,name ,args ,@config)
	    `(metacode-walker-all ,name ,args ,@config))))
