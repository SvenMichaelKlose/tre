;;;;; TRE compiler
;;;;; Copyright (c) 2010 Sven Klose <pixel@copei.de>

(defmacro metacode-walker (name args &key (if-atom nil)
					  	    		      (if-symbol nil)
										  (if-function nil)
										  (if-lambda nil)
										  (if-named-function nil)
										  (if-slot-value nil)
										  (if-stack nil)
										  (if-vec nil)
										  (traverse? nil))
  (with-cons x r args
    `(defun ,name ,args
       (if (atom ,x)
	       (if (not ,x) nil
	           ,@(awhen if-symbol
				   `((symbolp ,x) ,!))
	           ,@(awhen if-atom
				   `((atom ,x) ,!)))
	      (if
			(in? (car ,x) '%quote '%var '%transpiler-native)
				,x
	         ,@(awhen if-symbol
				 `((symbolp ,x) ,!))
			,@(awhen if-slot-value
				`((%slot-value? ,x)	,!))
			,@(awhen if-stack
				`((%stack? ,x)		,!))
			,@(awhen if-vec
				`((%vec? ,x)		,!))
			(named-function-expr? ,x)
			  (progn
				,@(awhen (or if-named-function if-function)
					(list !))
	            (,name (cdr ,x) ,@r))
	        (lambda? ,x)
			  (progn
				,@(awhen (or if-lambda if-function)
					(list !))
	            (,name (cdr ,x) ,@r))
	        (,(if traverse?
				  'progn
				  'cons)
	          (,name (car ,x) ,@r)
	          (,name (cdr ,x) ,@r)))))))
