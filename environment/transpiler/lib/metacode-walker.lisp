;;;;; tré – Copyright (c) 2010–2012 Sven Michael Klose <pixel@copei.de>

(defun function-copier (x statement)
  `(copy-lambda ,x :body ,statement))

(defun metacode-walker-copier (x statement &key (%setq? nil))
  (? %setq?
     (list 'backquote `(%setq ,(list 'quasiquote `(%setq-place (car ,x)))
						      ,(list 'quasiquote `(let ,x (%setq-value (car ,x))
                                                    ,(function-copier x statement)))))
     `(let ,x (car ,x)
        ,(function-copier x statement))))

(defun metacode-statement? (x)
  (| (in? x. '%setq '%set-vec '%var '%function-prologue '%function-epilogue '%function-return '%%tag)
	 (vm-jump? x)
     (%%vm-call-nil? x)))

(defmacro metacode-walker (name args &key (if-atom nil)
					  	    	          (if-cons nil)
					  	    	          (if-symbol nil)
									      (if-function nil)
									      (if-lambda nil)
									      (if-named-function nil)
									      (if-slot-value nil)
									      (if-stack nil)
									      (if-vec nil)
									      (copy-function-heads? nil))
  (with-cons x r args
             (print
    (with-gensym v
      `(defun ,name ,args
         (when ,x
           (let ,v (car ,x)
             (cons (?
		             (atom ,v)
                       (let ,x (car ,x)
                         ,(? (| if-symbol if-atom)
                             `(?
                                (not ,v) nil
	                            ,@(awhen if-symbol  `((symbol? ,v) ,!))
	                            ,@(awhen if-atom    `((atom ,v)    ,!))
                                ,v)
                             v))
                     ,@(awhen if-slot-value  `((%slot-value? ,v)  ,!))
		             ,@(awhen if-stack       `((%stack? ,v)	      ,!))
		             ,@(awhen if-vec         `((%vec? ,v)         ,!))

		             ,@(alet (| if-named-function if-function `(,name (lambda-body ,x) ,@r))
			             `((%setq-named-function? ,v) ,(metacode-walker-copier x ! :%setq? t)
			               (named-lambda? ,v) ,(metacode-walker-copier x !)))

		             ,@(alet (| if-lambda if-function `(,name (lambda-body ,x) ,@r))
			             `((%setq-lambda? ,v) ,(metacode-walker-copier x ! :%setq? t)))

		             (not (metacode-statement? ,v))
			             (& (print ,v)
			                (error "metacode statement expected instead"))

                     ,(| if-cons v))
                  (,name (cdr ,x) ,@r))))))))
  )
