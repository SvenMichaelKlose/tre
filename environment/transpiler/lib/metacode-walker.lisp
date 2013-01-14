;;;;; tré – Copyright (c) 2010–2013 Sven Michael Klose <pixel@copei.de>

(defun function-copier (x statement)
  `(copy-lambda (car ,x) :body ,statement))

(defun metacode-walker-copier-setq (x statement)
   (list 'backquote `((%setq ,(list 'quasiquote `(%setq-place (car ,x)))
                             ,(list 'quasiquote `(let ,x (%setq-value (car ,x))
                                                   ,(function-copier x statement)))))))

(defun metacode-walker-copier (x statement)
   `(list ,(function-copier x statement)))

(defun metacode-statement? (x)
  (| (in? x. '%setq '%set-vec '%var '%function-prologue '%function-epilogue '%function-return '%%tag)
	 (vm-jump? x)
     (%%vm-call-nil? x)))

(defmacro metacode-walker (name args &key (if-atom nil)
					  	    	          (if-cons nil)
					  	    	          (if-symbol nil)
					  	    	          (if-setq nil)
					  	    	          (if-go nil)
					  	    	          (if-go-nil nil)
									      (if-function nil)
									      (if-lambda nil)
									      (if-named-function nil)
									      (if-slot-value nil)
									      (if-stack nil)
									      (if-vec nil)
									      (copy-function-heads? nil))
  (with-cons x r args
    (with-gensym v
      `(defun ,name ,args
         (when ,x
           (let ,v (car ,x)
             (+ (?
                  (atom ,v)
                    (let ,x (car ,x)
                      ,(? (| if-symbol if-atom)
                          `(?
                             (not ,v) nil
                             ,@(!? if-symbol  `((symbol? ,v) ,!))
                             ,@(!? if-atom    `((atom ,v)    ,!))
                             (list ,v))
                          `(list ,v)))

                  ,@(!? if-setq        `((%setq? ,v)        ,!))
                  ,@(!? if-go          `((%%vm-go? ,v)      ,!))
                  ,@(!? if-go-nil      `((%%vm-go-nil? ,v)  ,!))
                  ,@(!? if-slot-value  `((%slot-value? ,v)  ,!))
                  ,@(!? if-stack       `((%stack? ,v)       ,!))
                  ,@(!? if-vec         `((%vec? ,v)         ,!))

                  ,@(alet (| if-named-function if-function `(,name (lambda-body ,v) ,@r))
                      `((%setq-named-function? ,v) ,(metacode-walker-copier-setq x !)
                        (named-lambda? ,v) ,(metacode-walker-copier x !)))

                  ,@(alet (| if-lambda if-function `(,name (lambda-body ,v) ,@r))
                      `((%setq-lambda? ,v) ,(metacode-walker-copier-setq x !)))

                  (not (metacode-statement? ,v))
                    (& (print ,v)
                       (error "metacode statement expected instead"))

                  ,(| if-cons `(list ,v)))
                (,name (cdr ,x) ,@r))))))))
