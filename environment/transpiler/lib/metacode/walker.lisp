(var *body*)

(fn metacode-statement? (x)
  (| (in? x. '%= '%set-vec '%var '%function-prologue '%function-epilogue '%function-return '%%tag)
	 (vm-jump? x)
     (%%call-nil? x)))

(defmacro metacode-walker (name args &key (if-atom nil)
					  	    	          (if-cons nil)
					  	    	          (if-setq nil)
					  	    	          (if-go nil)
					  	    	          (if-go-nil nil)
					  	    	          (if-go-not-nil nil)
									      (if-named-function nil))
  (with-cons x r args
    (with-gensym v
      `(fn ,name ,args
         (when ,x
           (let ,v (car ,x)
             (+ (?
                  (atom ,v)             ,(| if-atom `(list ,v))
                  ,@(!? if-setq         `((%=? ,v) ,!))
                  ,@(!? if-go           `((%%go? ,v) ,!))
                  ,@(!? if-go-nil       `((%%go-nil? ,v) ,!))
                  ,@(!? if-go-not-nil   `((%%go-not-nil? ,v) ,!))
                  (%%call-nil? ,v)      (list ,v)
                  (%%call-not-nil? ,v)  (list ,v)
                  (%%comment? ,v)       (list ,v)
                  (named-lambda? ,v)    (with-lambda-funinfo ,v
                                          (list (copy-lambda ,v :body ,(| if-named-function
                                                                          `(,name (lambda-body ,v) ,@r)))))
                  (not (metacode-statement? ,v))
                     (funinfo-error "Metacode statement expected instead of ~A." ,v)
                  ,(| if-cons `(list ,v)))
                (,name (cdr ,x) ,@r))))))))
